import { Test, TestingModule } from '@nestjs/testing';
import { RankingService } from './ranking.service';
import { PrismaService } from '../prisma/prisma.service';

const mockPredictions = [
  {
    userId: 'user-1',
    matchId: 'match-1',
    homeGoals: 2,
    awayGoals: 1,
    match: {
      id: 'match-1',
      status: 'FINISHED',
      homeGoals: 2,
      awayGoals: 1,
    },
  },
  {
    userId: 'user-1',
    matchId: 'match-2',
    homeGoals: 1,
    awayGoals: 1,
    match: {
      id: 'match-2',
      status: 'FINISHED',
      homeGoals: 0,
      awayGoals: 0,
    },
  },
  {
    userId: 'user-1',
    matchId: 'match-3',
    homeGoals: 3,
    awayGoals: 0,
    match: {
      id: 'match-3',
      status: 'FINISHED',
      homeGoals: 2,
      awayGoals: 0,
    },
  },
  {
    userId: 'user-1',
    matchId: 'match-4',
    homeGoals: 0,
    awayGoals: 1,
    match: {
      id: 'match-4',
      status: 'FINISHED',
      homeGoals: 0,
      awayGoals: 2,
    },
  },
  {
    userId: 'user-1',
    matchId: 'match-5',
    homeGoals: 1,
    awayGoals: 0,
    match: {
      id: 'match-5',
      status: 'FINISHED',
      homeGoals: 0,
      awayGoals: 1,
    },
  },
];

describe('RankingService', () => {
  let service: RankingService;
  let prisma: PrismaService;

  const mockPrismaService = {
    prediction: {
      findMany: jest.fn().mockResolvedValue(mockPredictions),
    },
    roundPayment: {
      findMany: jest.fn().mockResolvedValue([{ round: 1 }]),
    },
    ranking: {
      upsert: jest.fn().mockResolvedValue({}),
      findMany: jest.fn().mockResolvedValue([]),
      update: jest.fn().mockResolvedValue({}),
      count: jest.fn().mockResolvedValue(0),
      findUnique: jest.fn().mockResolvedValue({}),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RankingService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<RankingService>(RankingService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('calculateRankingForUser', () => {
    it('should calculate points correctly for various prediction scenarios', async () => {
      await service.calculateRankingForUser('user-1');

      expect(prisma.roundPayment.findMany).toHaveBeenCalledWith({
        where: { userId: 'user-1', paid: true },
        select: { round: true },
      });
      expect(prisma.prediction.findMany).toHaveBeenCalledWith({
        where: {
          userId: 'user-1',
          match: { status: 'FINISHED' },
        },
        include: { match: true },
      });

      // match-1: exact score (2-1 vs 2-1) -> +10 pts, exactScore=1, correctWinner=1
      // match-2: correct draw (1-1 vs 0-0) -> +5 pts, exactScore=0, correctWinner=1
      // match-3: correct winner & 1 team goals (3-0 vs 2-0, away 0=0) -> 5 + 2 = +7 pts, exactScore=0, correctWinner=1
      // match-4: correct winner & 1 team goals (0-1 vs 0-2, home 0=0) -> 5 + 2 = +7 pts, exactScore=0, correctWinner=1
      // match-5: incorrect outcome & 0 team goals (1-0 vs 0-1) -> +0 pts, exactScore=0, correctWinner=0
      // Total points: 10 + 5 + 7 + 7 + 0 = 29
      // Total exact scores: 1
      // Total correct winners: 4

      expect(prisma.ranking.upsert).toHaveBeenCalledWith({
        where: { userId: 'user-1' },
        update: {
          points: 29,
          exactScores: 1,
          correctWinners: 4,
        },
        create: {
          userId: 'user-1',
          points: 29,
          exactScores: 1,
          correctWinners: 4,
          position: 0,
        },
      });
    });
  });

  describe('refreshGlobalRankingPositions', () => {
    it('should sort rankings and update positions correctly', async () => {
      const mockRankings = [
        {
          id: 'r1',
          points: 10,
          exactScores: 0,
          correctWinners: 1,
          user: { createdAt: new Date('2026-01-02') },
        },
        {
          id: 'r2',
          points: 20,
          exactScores: 1,
          correctWinners: 2,
          user: { createdAt: new Date('2026-01-01') },
        },
        {
          id: 'r3',
          points: 10,
          exactScores: 1,
          correctWinners: 1,
          user: { createdAt: new Date('2026-01-01') },
        },
        {
          id: 'r4',
          points: 10,
          exactScores: 0,
          correctWinners: 1,
          user: { createdAt: new Date('2026-01-01') },
        },
      ];

      jest
        .spyOn(prisma.ranking, 'findMany')
        .mockResolvedValueOnce(mockRankings as any);

      await service.refreshGlobalRankingPositions();

      // Expected order:
      // 1. r2 (20 points)
      // 2. r3 (10 points, 1 exact score)
      // 3. r4 (10 points, 0 exact, 1 correct winner, created earlier)
      // 4. r1 (10 points, 0 exact, 1 correct winner, created later)

      expect(prisma.ranking.update).toHaveBeenCalledTimes(4);
      expect(prisma.ranking.update).toHaveBeenNthCalledWith(1, {
        where: { id: 'r2' },
        data: { position: 1 },
      });
      expect(prisma.ranking.update).toHaveBeenNthCalledWith(2, {
        where: { id: 'r3' },
        data: { position: 2 },
      });
      expect(prisma.ranking.update).toHaveBeenNthCalledWith(3, {
        where: { id: 'r4' },
        data: { position: 3 },
      });
      expect(prisma.ranking.update).toHaveBeenNthCalledWith(4, {
        where: { id: 'r1' },
        data: { position: 4 },
      });
    });
  });

  describe('updateRankingsForMatch', () => {
    it('should update rankings for all users who predicted the match', async () => {
      const mockMatchPredictions = [{ userId: 'user-1' }, { userId: 'user-2' }];
      jest
        .spyOn(prisma.prediction, 'findMany')
        .mockResolvedValueOnce(mockMatchPredictions as any);

      jest
        .spyOn(service, 'calculateRankingForUser')
        .mockResolvedValue(undefined);
      jest
        .spyOn(service, 'refreshGlobalRankingPositions')
        .mockResolvedValue(undefined);

      await service.updateRankingsForMatch('match-1');

      expect(service.calculateRankingForUser).toHaveBeenCalledWith('user-1');
      expect(service.calculateRankingForUser).toHaveBeenCalledWith('user-2');
      expect(service.refreshGlobalRankingPositions).toHaveBeenCalled();
    });
  });
});
