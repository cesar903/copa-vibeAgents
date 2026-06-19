import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsNotEmpty, IsUUID, Min } from 'class-validator';

export class CreatePredictionDto {
  @ApiProperty({ example: 'uuid-match-id', description: 'ID da partida' })
  @IsUUID()
  @IsNotEmpty()
  matchId: string;

  @ApiProperty({ example: 2, description: 'Gols do time da casa' })
  @IsInt()
  @Min(0)
  @IsNotEmpty()
  homeGoals: number;

  @ApiProperty({ example: 1, description: 'Gols do time visitante' })
  @IsInt()
  @Min(0)
  @IsNotEmpty()
  awayGoals: number;
}
