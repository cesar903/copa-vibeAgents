import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpsertRoundPaymentDto } from './dto/upsert-round-payment.dto';
import { RankingService } from '../ranking/ranking.service';

@Injectable()
export class RoundPaymentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly rankingService: RankingService,
  ) {}

  async findByRound(round = 1) {
    const users = await this.prisma.user.findMany({
      orderBy: { name: 'asc' },
      select: {
        id: true,
        name: true,
        email: true,
        roundPayments: {
          where: { round },
          select: { id: true, round: true, paid: true, paidAt: true },
        },
      },
    });

    return users.map((user) => {
      const payment = user.roundPayments[0];
      return {
        id: payment?.id,
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
        round,
        paid: payment?.paid ?? false,
        paidAt: payment?.paidAt ?? null,
      };
    });
  }

  async upsert(dto: UpsertRoundPaymentDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
      select: { id: true },
    });

    if (!user) {
      throw new NotFoundException('Usuário não encontrado.');
    }

    const payment = await this.prisma.roundPayment.upsert({
      where: {
        userId_round: {
          userId: dto.userId,
          round: dto.round,
        },
      },
      update: {
        paid: dto.paid,
        paidAt: dto.paid ? new Date() : null,
      },
      create: {
        userId: dto.userId,
        round: dto.round,
        paid: dto.paid,
        paidAt: dto.paid ? new Date() : null,
      },
    });

    await this.rankingService.calculateRankingForUser(dto.userId);
    await this.rankingService.refreshGlobalRankingPositions();

    return payment;
  }
}
