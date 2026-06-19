import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';
export declare class NotificationsService {
    create(_createNotificationDto: CreateNotificationDto): string;
    findAll(): string;
    findOne(id: string): string;
    update(id: string, _updateNotificationDto: UpdateNotificationDto): string;
    remove(id: string): string;
}
