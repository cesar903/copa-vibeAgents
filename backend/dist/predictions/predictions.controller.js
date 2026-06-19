"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PredictionsController = void 0;
const common_1 = require("@nestjs/common");
const predictions_service_1 = require("./predictions.service");
const create_prediction_dto_1 = require("./dto/create-prediction.dto");
const update_prediction_dto_1 = require("./dto/update-prediction.dto");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const current_user_decorator_1 = require("../auth/current-user.decorator");
let PredictionsController = class PredictionsController {
    predictionsService;
    constructor(predictionsService) {
        this.predictionsService = predictionsService;
    }
    create(user, createPredictionDto) {
        return this.predictionsService.createOrUpdate(user.id, createPredictionDto);
    }
    findAllByUser(user) {
        return this.predictionsService.findAllByUser(user.id);
    }
    findByMatch(user, matchId) {
        return this.predictionsService.findByMatch(user.id, matchId);
    }
    findOne(user, id) {
        return this.predictionsService.findOne(user.id, id);
    }
    update(user, id, updatePredictionDto) {
        return this.predictionsService.update(user.id, id, updatePredictionDto);
    }
    remove(user, id) {
        return this.predictionsService.remove(user.id, id);
    }
};
exports.PredictionsController = PredictionsController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: 'Create or update a prediction (upsert)' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: 'Prediction created/updated.' }),
    (0, swagger_1.ApiResponse)({
        status: 403,
        description: 'Time limit to predict has expired.',
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_prediction_dto_1.CreatePredictionDto]),
    __metadata("design:returntype", void 0)
], PredictionsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Get all predictions of the current logged user' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'List of predictions.' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], PredictionsController.prototype, "findAllByUser", null);
__decorate([
    (0, common_1.Get)('match/:matchId'),
    (0, swagger_1.ApiOperation)({ summary: 'Get all predictions for a specific match' }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: 'List of predictions. Hide others if match has not started.',
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('matchId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], PredictionsController.prototype, "findByMatch", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Get a specific prediction by ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Return prediction if visible.' }),
    (0, swagger_1.ApiResponse)({
        status: 403,
        description: 'Forbidden to see others prediction before match starts.',
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], PredictionsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Update a prediction' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Prediction updated.' }),
    (0, swagger_1.ApiResponse)({
        status: 403,
        description: 'Time limit to predict has expired.',
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, update_prediction_dto_1.UpdatePredictionDto]),
    __metadata("design:returntype", void 0)
], PredictionsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, swagger_1.ApiOperation)({ summary: 'Delete a prediction' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Prediction deleted.' }),
    (0, swagger_1.ApiResponse)({
        status: 403,
        description: 'Time limit to predict has expired.',
    }),
    __param(0, (0, current_user_decorator_1.CurrentUser)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", void 0)
], PredictionsController.prototype, "remove", null);
exports.PredictionsController = PredictionsController = __decorate([
    (0, swagger_1.ApiTags)('predictions'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('predictions'),
    __metadata("design:paramtypes", [predictions_service_1.PredictionsService])
], PredictionsController);
//# sourceMappingURL=predictions.controller.js.map