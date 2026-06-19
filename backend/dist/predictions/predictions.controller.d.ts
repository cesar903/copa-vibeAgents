import { PredictionsService } from './predictions.service';
import { CreatePredictionDto } from './dto/create-prediction.dto';
import { UpdatePredictionDto } from './dto/update-prediction.dto';
import type { User } from '@prisma/client';
export declare class PredictionsController {
    private readonly predictionsService;
    constructor(predictionsService: PredictionsService);
    create(user: User, createPredictionDto: CreatePredictionDto): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeGoals: number;
        awayGoals: number;
        userId: string;
        matchId: string;
        locked: boolean;
    }>;
    findAllByUser(user: User): Promise<({
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
    findByMatch(user: User, matchId: string): Promise<({
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
    findOne(user: User, id: string): Promise<{
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
    update(user: User, id: string, updatePredictionDto: UpdatePredictionDto): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        homeGoals: number;
        awayGoals: number;
        userId: string;
        matchId: string;
        locked: boolean;
    }>;
    remove(user: User, id: string): Promise<{
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
