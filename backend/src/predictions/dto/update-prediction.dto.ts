import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsInt, IsOptional, Min } from 'class-validator';

export class UpdatePredictionDto {
  @ApiPropertyOptional({ example: 2, description: 'Gols do time da casa' })
  @IsInt()
  @Min(0)
  @IsOptional()
  homeGoals?: number;

  @ApiPropertyOptional({ example: 1, description: 'Gols do time visitante' })
  @IsInt()
  @Min(0)
  @IsOptional()
  awayGoals?: number;
}
