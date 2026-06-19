import { CreatePredictionDto } from './dto/create-prediction.dto';
import { UpdatePredictionDto } from './dto/update-prediction.dto';
import { PrismaService } from '../prisma/prisma.service';
export declare class PredictionsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    private checkTimeLimit;
    createOrUpdate(userId: string, createPredictionDto: CreatePredictionDto): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeGoals: number;
        awayGoals: number;
        userId: string;
        matchId: string;
        locked: boolean;
    }>;
    findAllByUser(userId: string): Promise<({
        match: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            homeTeam: string;
            awayTeam: string;
            competition: string;
            stadium: string;
            startDate: Date;
            status: import("@prisma/client").$Enums.MatchStatus;
            homeGoals: number | null;
            awayGoals: number | null;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeGoals: number;
        awayGoals: number;
        userId: string;
        matchId: string;
        locked: boolean;
    })[]>;
    findByMatch(currentUserId: string, matchId: string): Promise<({
        user: {
            name: string;
            avatar: string | null;
            id: string;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeGoals: number;
        awayGoals: number;
        userId: string;
        matchId: string;
        locked: boolean;
    })[]>;
    findOne(userId: string, id: string): Promise<{
        match: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            homeTeam: string;
            awayTeam: string;
            competition: string;
            stadium: string;
            startDate: Date;
            status: import("@prisma/client").$Enums.MatchStatus;
            homeGoals: number | null;
            awayGoals: number | null;
        };
    } & {
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeGoals: number;
        awayGoals: number;
        userId: string;
        matchId: string;
        locked: boolean;
    }>;
    update(userId: string, id: string, updatePredictionDto: UpdatePredictionDto): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeGoals: number;
        awayGoals: number;
        userId: string;
        matchId: string;
        locked: boolean;
    }>;
    remove(userId: string, id: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeGoals: number;
        awayGoals: number;
        userId: string;
        matchId: string;
        locked: boolean;
    }>;
}
