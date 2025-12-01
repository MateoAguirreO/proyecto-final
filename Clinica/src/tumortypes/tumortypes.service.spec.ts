import { Test, TestingModule } from '@nestjs/testing';
import { TumortypesService } from './tumortypes.service';

describe('TumortypesService', () => {
  let service: TumortypesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TumortypesService],
    }).compile();

    service = module.get<TumortypesService>(TumortypesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
