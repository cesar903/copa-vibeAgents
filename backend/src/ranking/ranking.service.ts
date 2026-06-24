import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RankingQueryDto } from './dto/ranking-query.dto';

@Injectable()
export class RankingService {
  constructor(private readonly prisma: PrismaService) {}

  async calculateRankingForUser(userId: string) {
    const paidRounds = await this.prisma.roundPayment.findMany({
      where: { userId, paid: true },
      select: { round: true },
    });
    const paidRoundNumbers = paidRounds.map((payment) => payment.round);

    const predictions = await this.prisma.prediction.findMany({
      where: {
        userId,
        match: {
          status: 'FINISHED',
          round: { in: paidRoundNumbers },
        },
      },
      include: { match: true },
    });

    let totalPoints = 0;
    let totalExactScores = 0;
    let totalCorrectWinners = 0;

    for (const pred of predictions) {
      if (pred.match.homeGoals == null || pred.match.awayGoals == null)
        continue;

      const matchHome = pred.match.homeGoals;
      const matchAway = pred.match.awayGoals;

      const isExact =
        pred.homeGoals === matchHome && pred.awayGoals === matchAway;
      const isCorrectOutcome =
        Math.sign(matchHome - matchAway) ===
        Math.sign(pred.homeGoals - pred.awayGoals);

      if (isExact) {
        totalPoints += 10;
        totalExactScores += 1;
        totalCorrectWinners += 1;
      } else {
        if (isCorrectOutcome) {
          totalPoints += 5;
          totalCorrectWinners += 1;
        }
        if (pred.homeGoals === matchHome) {
          totalPoints += 2;
        }
        if (pred.awayGoals === matchAway) {
          totalPoints += 2;
        }
      }
    }

    await this.prisma.ranking.upsert({
      where: { userId },
      update: {
        points: totalPoints,
        exactScores: totalExactScores,
        correctWinners: totalCorrectWinners,
      },
      create: {
        userId,
        points: totalPoints,
        exactScores: totalExactScores,
        correctWinners: totalCorrectWinners,
        position: 0,
      },
    });
  }

  async updateRankingsForMatch(matchId: string) {
    const predictions = await this.prisma.prediction.findMany({
      where: { matchId },
      select: { userId: true },
    });

    // We can do this in parallel or sequentially.
    // Sequentially is safer to not overwhelm DB if many predictions.
    for (const pred of predictions) {
      await this.calculateRankingForUser(pred.userId);
    }

    await this.refreshGlobalRankingPositions();
  }

  async refreshGlobalRankingPositions() {
    const rankings = await this.prisma.ranking.findMany({
      include: { user: { select: { createdAt: true } } },
    });

    // Sort according to rules:
    // 1. Points DESC
    // 2. Exact Scores DESC
    // 3. Correct Winners DESC
    // 4. User CreatedAt ASC
    rankings.sort((a, b) => {
      if (b.points !== a.points) return b.points - a.points;
      if (b.exactScores !== a.exactScores) return b.exactScores - a.exactScores;
      if (b.correctWinners !== a.correctWinners)
        return b.correctWinners - a.correctWinners;
      return a.user.createdAt.getTime() - b.user.createdAt.getTime();
    });

    // Update positions
    for (let i = 0; i < rankings.length; i++) {
      const position = i + 1;
      if (rankings[i].position !== position) {
        await this.prisma.ranking.update({
          where: { id: rankings[i].id },
          data: { position },
        });
      }
    }
  }

  async findAll(query: RankingQueryDto = {}) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 10;
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      this.prisma.ranking.findMany({
        skip,
        take: limit,
        orderBy: { position: 'asc' },
        include: {
          user: {
            select: { id: true, name: true, avatar: true },
          },
        },
      }),
      this.prisma.ranking.count(),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(userId: string) {
    return this.prisma.ranking.findUnique({
      where: { userId },
      include: {
        user: {
          select: { id: true, name: true, avatar: true },
        },
      },
    });
  }
}
