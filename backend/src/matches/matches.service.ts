import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateMatchDto } from './dto/create-match.dto';
import { UpdateMatchDto } from './dto/update-match.dto';
import { PrismaService } from '../prisma/prisma.service';
import { RankingService } from '../ranking/ranking.service';
import { MatchQueryDto } from './dto/match-query.dto';
import { Prisma } from '@prisma/client';

@Injectable()
export class MatchesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly rankingService: RankingService,
  ) {}

  async create(createMatchDto: CreateMatchDto) {
    return this.prisma.match.create({
      data: {
        homeTeam: createMatchDto.homeTeam,
        awayTeam: createMatchDto.awayTeam,
        competition: createMatchDto.competition,
        stadium: createMatchDto.stadium,
        startDate: new Date(createMatchDto.startDate),
        status: createMatchDto.status,
        homeGoals: createMatchDto.homeGoals,
        awayGoals: createMatchDto.awayGoals,
      },
    });
  }

  async findAll(query: MatchQueryDto) {
    const { status, competition, date, page = 1, limit = 10 } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.MatchWhereInput = {};

    if (status) {
      where.status = status;
    }

    if (competition) {
      where.competition = { contains: competition, mode: 'insensitive' };
    }

    if (date) {
      const startOfDay = new Date(date);
      startOfDay.setUTCHours(0, 0, 0, 0);

      const endOfDay = new Date(date);
      endOfDay.setUTCHours(23, 59, 59, 999);

      where.startDate = {
        gte: startOfDay,
        lte: endOfDay,
      };
    }

    const [data, total] = await Promise.all([
      this.prisma.match.findMany({
        where,
        skip,
        take: limit,
        orderBy: { startDate: 'asc' },
      }),
      this.prisma.match.count({ where }),
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

  async findOne(id: string) {
    const match = await this.prisma.match.findUnique({
      where: { id },
    });

    if (!match) {
      throw new NotFoundException(`Match with ID ${id} not found`);
    }

    return match;
  }

  async update(id: string, updateMatchDto: UpdateMatchDto) {
    await this.findOne(id); // Ensure it exists

    const updateData: Prisma.MatchUpdateInput = {
      ...updateMatchDto,
    };

    if (updateMatchDto.startDate) {
      updateData.startDate = new Date(updateMatchDto.startDate);
    }

    const updatedMatch = await this.prisma.match.update({
      where: { id },
      data: updateData,
    });

    // Update rankings if match is updated, especially if finished or scores changed
    if (updatedMatch.status === 'FINISHED') {
      await this.rankingService.updateRankingsForMatch(id);
    }

    return updatedMatch;
  }

  async remove(id: string) {
    await this.findOne(id); // Ensure it exists

    return this.prisma.match.delete({
      where: { id },
    });
  }
}
