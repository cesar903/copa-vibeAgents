import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { CreatePredictionDto } from './dto/create-prediction.dto';
import { UpdatePredictionDto } from './dto/update-prediction.dto';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PredictionsService {
  constructor(private readonly prisma: PrismaService) {}

  private checkTimeLimit(startDate: Date) {
    const limitTime = new Date(startDate.getTime() - 15 * 60 * 1000); // 15 minutos antes
    if (new Date() >= limitTime) {
      throw new ForbiddenException(
        'O prazo para criação ou edição de palpites desta partida foi encerrado.',
      );
    }
  }

  async createOrUpdate(
    userId: string,
    createPredictionDto: CreatePredictionDto,
  ) {
    const match = await this.prisma.match.findUnique({
      where: { id: createPredictionDto.matchId },
    });

    if (!match) {
      throw new NotFoundException('Partida não encontrada.');
    }

    this.checkTimeLimit(match.startDate);

    return this.prisma.prediction.upsert({
      where: {
        userId_matchId: {
          userId,
          matchId: createPredictionDto.matchId,
        },
      },
      update: {
        homeGoals: createPredictionDto.homeGoals,
        awayGoals: createPredictionDto.awayGoals,
      },
      create: {
        userId,
        matchId: createPredictionDto.matchId,
        homeGoals: createPredictionDto.homeGoals,
        awayGoals: createPredictionDto.awayGoals,
      },
    });
  }

  async findAllByUser(userId: string) {
    return this.prisma.prediction.findMany({
      where: { userId },
      include: {
        match: true,
      },
      orderBy: {
        match: { startDate: 'asc' },
      },
    });
  }

  async findByMatch(currentUserId: string, matchId: string) {
    const match = await this.prisma.match.findUnique({
      where: { id: matchId },
    });

    if (!match) {
      throw new NotFoundException('Partida não encontrada.');
    }

    const predictions = await this.prisma.prediction.findMany({
      where: { matchId },
      include: { user: { select: { id: true, name: true, avatar: true } } },
    });

    const hasStarted =
      new Date() >= match.startDate || match.status !== 'SCHEDULED';

    // Regra: Antes do início da partida, não visualizar palpites dos demais
    if (!hasStarted) {
      return predictions.filter((p) => p.userId === currentUserId);
    }

    // Durante ou após: Todos os palpites visíveis
    return predictions;
  }

  async findOne(userId: string, id: string) {
    const prediction = await this.prisma.prediction.findUnique({
      where: { id },
      include: { match: true },
    });

    if (!prediction) {
      throw new NotFoundException('Palpite não encontrado.');
    }

    // Pode visualizar se for o dono, ou se a partida já tiver começado
    const hasStarted =
      new Date() >= prediction.match.startDate ||
      prediction.match.status !== 'SCHEDULED';

    if (prediction.userId !== userId && !hasStarted) {
      throw new ForbiddenException(
        'Você não pode visualizar este palpite antes do início da partida.',
      );
    }

    return prediction;
  }

  async update(
    userId: string,
    id: string,
    updatePredictionDto: UpdatePredictionDto,
  ) {
    const prediction = await this.prisma.prediction.findUnique({
      where: { id },
      include: { match: true },
    });

    if (!prediction) {
      throw new NotFoundException('Palpite não encontrado.');
    }

    if (prediction.userId !== userId) {
      throw new ForbiddenException(
        'Você não tem permissão para editar este palpite.',
      );
    }

    this.checkTimeLimit(prediction.match.startDate);

    return this.prisma.prediction.update({
      where: { id },
      data: updatePredictionDto,
    });
  }

  async remove(userId: string, id: string) {
    const prediction = await this.prisma.prediction.findUnique({
      where: { id },
      include: { match: true },
    });

    if (!prediction) {
      throw new NotFoundException('Palpite não encontrado.');
    }

    if (prediction.userId !== userId) {
      throw new ForbiddenException(
        'Você não tem permissão para remover este palpite.',
      );
    }

    this.checkTimeLimit(prediction.match.startDate);

    return this.prisma.prediction.delete({
      where: { id },
    });
  }
}
