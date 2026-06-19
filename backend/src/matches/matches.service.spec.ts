import { Test, TestingModule } from '@nestjs/testing';
import { MatchesService } from './matches.service';
import { PrismaService } from '../prisma/prisma.service';
import { RankingService } from '../ranking/ranking.service';
import { MatchStatus } from '@prisma/client';
import { NotFoundException } from '@nestjs/common';

const mockMatch = {
  id: 'match-1',
  homeTeam: 'Brazil',
  awayTeam: 'Argentina',
  competition: 'World Cup 2026',
  stadium: 'Maracanã',
  startDate: new Date('2026-06-16T16:00:00Z'),
  status: MatchStatus.SCHEDULED,
  homeGoals: null,
  awayGoals: null,
  createdAt: new Date(),
  updatedAt: new Date(),
};

describe('MatchesService', () => {
  let service: MatchesService;
  let prisma: PrismaService;
  let rankingService: RankingService;

  const mockPrismaService = {
    match: {
      create: jest.fn().mockResolvedValue(mockMatch),
      findMany: jest.fn().mockResolvedValue([mockMatch]),
      count: jest.fn().mockResolvedValue(1),
      findUnique: jest.fn().mockResolvedValue(mockMatch),
      update: jest
        .fn()
        .mockResolvedValue({ ...mockMatch, status: MatchStatus.LIVE }),
      delete: jest.fn().mockResolvedValue(mockMatch),
    },
  };

  const mockRankingService = {
    updateRankingsForMatch: jest.fn().mockResolvedValue(undefined),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MatchesService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: RankingService, useValue: mockRankingService },
      ],
    }).compile();

    service = module.get<MatchesService>(MatchesService);
    prisma = module.get<PrismaService>(PrismaService);
    rankingService = module.get<RankingService>(RankingService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a new match', async () => {
      const createDto = {
        homeTeam: 'Brazil',
        awayTeam: 'Argentina',
        competition: 'World Cup 2026',
        stadium: 'Maracanã',
        startDate: '2026-06-16T16:00:00Z',
        status: MatchStatus.SCHEDULED,
      };

      const result = await service.create(createDto);
      expect(prisma.match.create).toHaveBeenCalled();
      expect(result).toEqual(mockMatch);
    });
  });

  describe('findAll', () => {
    it('should return paginated matches', async () => {
      const result = await service.findAll({});
      expect(prisma.match.findMany).toHaveBeenCalled();
      expect(prisma.match.count).toHaveBeenCalled();
      expect(result.data).toEqual([mockMatch]);
      expect(result.meta.total).toBe(1);
    });
  });

  describe('findOne', () => {
    it('should return a match by id', async () => {
      const result = await service.findOne('match-1');
      expect(prisma.match.findUnique).toHaveBeenCalledWith({
        where: { id: 'match-1' },
      });
      expect(result).toEqual(mockMatch);
    });

    it('should throw NotFoundException if match not found', async () => {
      jest.spyOn(prisma.match, 'findUnique').mockResolvedValueOnce(null);
      await expect(service.findOne('invalid')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('update', () => {
    it('should update a match and update rankings if finished', async () => {
      const updatedMatchFinished = {
        ...mockMatch,
        status: MatchStatus.FINISHED,
      };
      jest.spyOn(prisma.match, 'findUnique').mockResolvedValueOnce(mockMatch);
      jest
        .spyOn(prisma.match, 'update')
        .mockResolvedValueOnce(updatedMatchFinished);

      const updateDto = { status: MatchStatus.FINISHED };
      const result = await service.update('match-1', updateDto);

      expect(prisma.match.update).toHaveBeenCalled();
      expect(result.status).toEqual(MatchStatus.FINISHED);
      expect(rankingService.updateRankingsForMatch).toHaveBeenCalledWith(
        'match-1',
      );
    });

    it('should update a match without updating rankings if not finished', async () => {
      const updatedMatchLive = { ...mockMatch, status: MatchStatus.LIVE };
      jest.spyOn(prisma.match, 'findUnique').mockResolvedValueOnce(mockMatch);
      jest
        .spyOn(prisma.match, 'update')
        .mockResolvedValueOnce(updatedMatchLive);

      const updateDto = { status: MatchStatus.LIVE };
      const result = await service.update('match-1', updateDto);

      expect(prisma.match.update).toHaveBeenCalled();
      expect(result.status).toEqual(MatchStatus.LIVE);
      expect(rankingService.updateRankingsForMatch).not.toHaveBeenCalled();
    });
  });

  describe('remove', () => {
    it('should delete a match', async () => {
      jest.spyOn(prisma.match, 'findUnique').mockResolvedValueOnce(mockMatch);

      const result = await service.remove('match-1');

      expect(prisma.match.delete).toHaveBeenCalledWith({
        where: { id: 'match-1' },
      });
      expect(result).toEqual(mockMatch);
    });
  });
});
