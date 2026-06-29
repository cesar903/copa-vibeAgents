import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsDateString,
  IsBoolean,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { MatchStatus } from '@prisma/client';

export class CreateMatchDto {
  @ApiProperty({ example: 'Brazil' })
  @IsString()
  @IsNotEmpty()
  homeTeam: string;

  @ApiProperty({ example: 'Argentina' })
  @IsString()
  @IsNotEmpty()
  awayTeam: string;

  @ApiProperty({ example: 'World Cup 2026' })
  @IsString()
  @IsNotEmpty()
  competition: string;

  @ApiProperty({ example: 'Maracanã' })
  @IsString()
  @IsNotEmpty()
  stadium: string;

  @ApiPropertyOptional({ example: 1, default: 1 })
  @IsInt()
  @Min(1)
  @IsOptional()
  round?: number;

  @ApiPropertyOptional({ example: true, default: true })
  @IsBoolean()
  @IsOptional()
  isMoneyPool?: boolean;

  @ApiProperty({ example: '2026-06-16T16:00:00Z' })
  @IsDateString()
  @IsNotEmpty()
  startDate: string;

  @ApiPropertyOptional({ enum: MatchStatus, default: MatchStatus.SCHEDULED })
  @IsEnum(MatchStatus)
  @IsOptional()
  status?: MatchStatus;

  @ApiPropertyOptional({ example: 2 })
  @IsNumber()
  @IsOptional()
  homeGoals?: number;

  @ApiPropertyOptional({ example: 1 })
  @IsNumber()
  @IsOptional()
  awayGoals?: number;
}
