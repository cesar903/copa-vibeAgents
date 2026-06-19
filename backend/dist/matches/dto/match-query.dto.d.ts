import { MatchStatus } from '@prisma/client';
export declare class MatchQueryDto {
    status?: MatchStatus;
    competition?: string;
    date?: string;
    page?: number;
    limit?: number;
}
