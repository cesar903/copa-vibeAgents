import { PrismaService } from '../prisma/prisma.service';
import { RankingQueryDto } from './dto/ranking-query.dto';
export declare class RankingService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    calculateRankingForUser(userId: string): Promise<void>;
    updateRankingsForMatch(matchId: string): Promise<void>;
    refreshGlobalRankingPositions(): Promise<void>;
    findAll(query?: RankingQueryDto): Promise<{
        data: ({
            user: {
                name: string;
                avatar: string | null;
                id: string;
            };
        } & {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            points: number;
            position: number;
            exactScores: number;
            correctWinners: number;
            userId: string;
        })[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    findOne(userId: string): Promise<({
        user: {
            name: string;
            avatar: string | null;
            id: string;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        points: number;
        position: number;
        exactScores: number;
        correctWinners: number;
        userId: string;
    }) | null>;
}
