import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import type { User } from '@prisma/client';
import type { Request } from 'express';

const DEFAULT_ADMIN_EMAIL = 'cesarreis521@gmail.com';

@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context
      .switchToHttp()
      .getRequest<Request & { user?: User }>();
    const adminEmail = (process.env.ADMIN_EMAIL ?? DEFAULT_ADMIN_EMAIL)
      .trim()
      .toLowerCase();

    if (request.user?.email.toLowerCase() !== adminEmail) {
      throw new ForbiddenException('Administrator access required');
    }

    return true;
  }
}
