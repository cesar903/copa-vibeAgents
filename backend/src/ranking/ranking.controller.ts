import { Controller, Get, Query, Param } from '@nestjs/common';
import { RankingService } from './ranking.service';
import { RankingQueryDto } from './dto/ranking-query.dto';

@Controller('ranking')
export class RankingController {
  constructor(private readonly rankingService: RankingService) {}

  @Get()
  findAll(@Query() query: RankingQueryDto) {
    return this.rankingService.findAll(query);
  }

  @Get(':userId')
  findOne(@Param('userId') userId: string) {
    return this.rankingService.findOne(userId);
  }
}
