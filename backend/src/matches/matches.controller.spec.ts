import { Test, TestingModule } from '@nestjs/testing';
import { MatchesController } from './matches.controller';
import { MatchesService } from './matches.service';
import { MatchStatus } from '@prisma/client';

const mockMatch = {
  id: 'match-1',
  homeTeam: 'Brazil',
  awayTeam: 'Argentina',
  competition: 'World Cup 2026',
  stadium: 'Maracanã',
  startDate: new Date('2026-06-16T16:00:00Z'),
  status: MatchStatus.SCHEDULED,
};

describe('MatchesController', () => {
  let controller: MatchesController;
  let service: MatchesService;

  const mockMatchesService = {
    create: jest.fn().mockResolvedValue(mockMatch),
    findAll: jest.fn().mockResolvedValue({
      data: [mockMatch],
      meta: { total: 1, page: 1, limit: 10, totalPages: 1 },
    }),
    findOne: jest.fn().mockResolvedValue(mockMatch),
    update: jest
      .fn()
      .mockResolvedValue({ ...mockMatch, status: MatchStatus.LIVE }),
    remove: jest.fn().mockResolvedValue(mockMatch),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [MatchesController],
      providers: [{ provide: MatchesService, useValue: mockMatchesService }],
    }).compile();

    controller = module.get<MatchesController>(MatchesController);
    service = module.get<MatchesService>(MatchesService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should create a match', async () => {
    const dto = {
      homeTeam: 'Brazil',
      awayTeam: 'Argentina',
      competition: 'World Cup 2026',
      stadium: 'Maracanã',
      startDate: '2026-06-16T16:00:00Z',
    };
    expect(await controller.create(dto)).toEqual(mockMatch);
    expect(service.create).toHaveBeenCalledWith(dto);
  });

  it('should find all matches', async () => {
    const query = { page: 1, limit: 10 };
    expect(await controller.findAll(query)).toEqual({
      data: [mockMatch],
      meta: { total: 1, page: 1, limit: 10, totalPages: 1 },
    });
    expect(service.findAll).toHaveBeenCalledWith(query);
  });

  it('should find one match', async () => {
    expect(await controller.findOne('match-1')).toEqual(mockMatch);
    expect(service.findOne).toHaveBeenCalledWith('match-1');
  });

  it('should update a match', async () => {
    const dto = { status: MatchStatus.LIVE };
    expect(await controller.update('match-1', dto)).toEqual({
      ...mockMatch,
      status: MatchStatus.LIVE,
    });
    expect(service.update).toHaveBeenCalledWith('match-1', dto);
  });

  it('should remove a match', async () => {
    expect(await controller.remove('match-1')).toEqual(mockMatch);
    expect(service.remove).toHaveBeenCalledWith('match-1');
  });
});
