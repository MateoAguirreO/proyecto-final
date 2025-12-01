import { Test, TestingModule } from '@nestjs/testing';
import { TumortypesController } from './tumortypes.controller';
import { TumortypesService } from './tumortypes.service';

describe('TumortypesController', () => {
  let controller: TumortypesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TumortypesController],
      providers: [TumortypesService],
    }).compile();

    controller = module.get<TumortypesController>(TumortypesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
