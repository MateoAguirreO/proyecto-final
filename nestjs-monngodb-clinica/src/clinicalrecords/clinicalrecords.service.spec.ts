import { Test, TestingModule } from '@nestjs/testing';
import { ClinicalrecordsService } from './clinicalrecords.service';

describe('ClinicalrecordsService', () => {
  let service: ClinicalrecordsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ClinicalrecordsService],
    }).compile();

    service = module.get<ClinicalrecordsService>(ClinicalrecordsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
