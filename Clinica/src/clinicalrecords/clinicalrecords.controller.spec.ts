import { Test, TestingModule } from '@nestjs/testing';
import { ClinicalrecordsController } from './clinicalrecords.controller';
import { ClinicalrecordsService } from './clinicalrecords.service';

describe('ClinicalrecordsController', () => {
  let controller: ClinicalrecordsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ClinicalrecordsController],
      providers: [ClinicalrecordsService],
    }).compile();

    controller = module.get<ClinicalrecordsController>(ClinicalrecordsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
