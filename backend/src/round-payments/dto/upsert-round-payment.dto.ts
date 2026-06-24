import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsInt, IsNotEmpty, IsString, Min } from 'class-validator';

export class UpsertRoundPaymentDto {
  @ApiProperty({ example: 'user-uuid' })
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({ example: 1 })
  @IsInt()
  @Min(1)
  round: number;

  @ApiProperty({ example: true })
  @IsBoolean()
  paid: boolean;
}
