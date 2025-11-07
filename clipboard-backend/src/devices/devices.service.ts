import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DevicesService {
  constructor(private prisma: PrismaService) {}

  async register(data: {
    deviceId: string;
    userId: number;
    deviceName?: string;
  }) {
    const existing = await this.prisma.device.findUnique({
      where: { id: data.deviceId },
    });

    if (existing) return existing;

    return this.prisma.device.create({
      data: {
        id: data.deviceId,
        userId: data.userId,
        deviceName: data.deviceName ?? 'Unknown Device',
      },
    });
  }
}
