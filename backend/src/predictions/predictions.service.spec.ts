import { Test, TestingModule } from '@nestjs/testing';
import { PredictionsService } from './predictions.service';
import { PrismaService } from '../prisma/prisma.service';
import { NotFoundException, ForbiddenException } from '@nestjs/common';
import { MatchStatus } from '@prisma/client';

describe('PredictionsService', () => {
  let service: PredictionsService;
  let prisma: PrismaService;

  const mockDate = new Date('2026-06-16T16:00:00Z');
  const nowMock = new Date('2026-06-16T10:00:00Z'); // 6 horas antes

  const mockMatch = {
    id: 'match-1',
    startDate: mockDate,
    status: MatchStatus.SCHEDULED,
  };

  const mockPrediction = {
    id: 'pred-1',
    userId: 'user-1',
    matchId: 'match-1',
    homeGoals: 2,
    awayGoals: 1,
    locked: false,
    match: mockMatch,
  };

  const mockPrismaService = {
    match: {
      findUnique: jest.fn().mockResolvedValue(mockMatch),
    },
    prediction: {
      upsert: jest.fn().mockResolvedValue(mockPrediction),
      findMany: jest.fn().mockResolvedValue([mockPrediction]),
      findUnique: jest.fn().mockResolvedValue(mockPrediction),
      update: jest.fn().mockResolvedValue(mockPrediction),
      delete: jest.fn().mockResolvedValue(mockPrediction),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PredictionsService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<PredictionsService>(PredictionsService);
    prisma = module.get<PrismaService>(PrismaService);

    // Mock de Date para testes com tempo
    jest.useFakeTimers();
    jest.setSystemTime(nowMock);
  });

  afterEach(() => {
    jest.useRealTimers();
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createOrUpdate', () => {
    it('should throw NotFoundException if match not found', async () => {
      jest.spyOn(prisma.match, 'findUnique').mockResolvedValueOnce(null);
      await expect(
        service.createOrUpdate('user-1', {
          matchId: 'match-x',
          homeGoals: 0,
          awayGoals: 0,
        }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw ForbiddenException if limit time exceeded', async () => {
      // Avança o tempo para 10 min antes da partida (limite é 15)
      jest.setSystemTime(new Date('2026-06-16T15:50:00Z'));

      await expect(
        service.createOrUpdate('user-1', {
          matchId: 'match-1',
          homeGoals: 0,
          awayGoals: 0,
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should upsert prediction', async () => {
      const result = await service.createOrUpdate('user-1', {
        matchId: 'match-1',
        homeGoals: 2,
        awayGoals: 1,
      });
      expect(prisma.prediction.upsert).toHaveBeenCalled();
      expect(result).toEqual(mockPrediction);
    });
  });

  describe('findByMatch (Visibility Rules)', () => {
    it('should hide other users predictions before match starts', async () => {
      const pred2 = { ...mockPrediction, userId: 'user-2', id: 'pred-2' };
      jest
        .spyOn(prisma.prediction, 'findMany')
        .mockResolvedValueOnce([mockPrediction, pred2] as any);

      const result = await service.findByMatch('user-1', 'match-1');
      expect(result).toHaveLength(1);
      expect(result[0].userId).toBe('user-1');
    });

    it('should show all predictions after match starts', async () => {
      // Avança o tempo para depois do início
      jest.setSystemTime(new Date('2026-06-16T17:00:00Z'));
      const pred2 = { ...mockPrediction, userId: 'user-2', id: 'pred-2' };
      jest
        .spyOn(prisma.prediction, 'findMany')
        .mockResolvedValueOnce([mockPrediction, pred2] as any);

      const result = await service.findByMatch('user-1', 'match-1');
      expect(result).toHaveLength(2);
    });
  });

  describe('update', () => {
    it('should throw Forbidden if not owner', async () => {
      await expect(
        service.update('wrong-user', 'pred-1', { homeGoals: 3 }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should update if owner and within time limit', async () => {
      const result = await service.update('user-1', 'pred-1', { homeGoals: 3 });
      expect(prisma.prediction.update).toHaveBeenCalled();
      expect(result).toEqual(mockPrediction);
    });
  });
});
