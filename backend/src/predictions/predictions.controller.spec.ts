import { Test, TestingModule } from '@nestjs/testing';
import { PredictionsController } from './predictions.controller';
import { PredictionsService } from './predictions.service';

const mockPrediction = {
  id: 'pred-1',
  userId: 'user-1',
  matchId: 'match-1',
  homeGoals: 2,
  awayGoals: 1,
};

const mockUser = { id: 'user-1', name: 'Test User' };

describe('PredictionsController', () => {
  let controller: PredictionsController;
  let service: PredictionsService;

  const mockPredictionsService = {
    createOrUpdate: jest.fn().mockResolvedValue(mockPrediction),
    findAllByUser: jest.fn().mockResolvedValue([mockPrediction]),
    findByMatch: jest.fn().mockResolvedValue([mockPrediction]),
    findOne: jest.fn().mockResolvedValue(mockPrediction),
    update: jest.fn().mockResolvedValue(mockPrediction),
    remove: jest.fn().mockResolvedValue(mockPrediction),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [PredictionsController],
      providers: [
        { provide: PredictionsService, useValue: mockPredictionsService },
      ],
    }).compile();

    controller = module.get<PredictionsController>(PredictionsController);
    service = module.get<PredictionsService>(PredictionsService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should create or update a prediction', async () => {
    const dto = { matchId: 'match-1', homeGoals: 2, awayGoals: 1 };
    expect(await controller.create(mockUser as any, dto)).toEqual(
      mockPrediction,
    );
    expect(service.createOrUpdate).toHaveBeenCalledWith('user-1', dto);
  });

  it('should find all predictions by user', async () => {
    expect(await controller.findAllByUser(mockUser as any)).toEqual([
      mockPrediction,
    ]);
    expect(service.findAllByUser).toHaveBeenCalledWith('user-1');
  });

  it('should find predictions by match', async () => {
    expect(await controller.findByMatch(mockUser as any, 'match-1')).toEqual([
      mockPrediction,
    ]);
    expect(service.findByMatch).toHaveBeenCalledWith('user-1', 'match-1');
  });

  it('should find one prediction', async () => {
    expect(await controller.findOne(mockUser as any, 'pred-1')).toEqual(
      mockPrediction,
    );
    expect(service.findOne).toHaveBeenCalledWith('user-1', 'pred-1');
  });

  it('should update a prediction', async () => {
    const dto = { homeGoals: 3 };
    expect(await controller.update(mockUser as any, 'pred-1', dto)).toEqual(
      mockPrediction,
    );
    expect(service.update).toHaveBeenCalledWith('user-1', 'pred-1', dto);
  });

  it('should remove a prediction', async () => {
    expect(await controller.remove(mockUser as any, 'pred-1')).toEqual(
      mockPrediction,
    );
    expect(service.remove).toHaveBeenCalledWith('user-1', 'pred-1');
  });
});
