import { Injectable } from '@nestjs/common';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { UpdateNotificationDto } from './dto/update-notification.dto';

@Injectable()
export class NotificationsService {
  create(_createNotificationDto: CreateNotificationDto) {
    void _createNotificationDto;
    return 'This action adds a new notification';
  }

  findAll() {
    return `This action returns all notifications`;
  }

  findOne(id: string) {
    return `This action returns a #${id} notification`;
  }

  update(id: string, _updateNotificationDto: UpdateNotificationDto) {
    void _updateNotificationDto;
    return `This action updates a #${id} notification`;
  }

  remove(id: string) {
    return `This action removes a #${id} notification`;
  }
}
