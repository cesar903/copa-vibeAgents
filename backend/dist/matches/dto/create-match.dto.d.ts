import { MatchStatus } from '@prisma/client';
export declare class CreateMatchDto {
    homeTeam: string;
    awayTeam: string;
    competition: string;
    stadium: string;
    startDate: string;
    status?: MatchStatus;
    homeGoals?: number;
    awayGoals?: number;
}
