import { Controller, Post, Body } from '@nestjs/common';
import { DevicesService } from './devices.service';

@Controller('devices')
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Post('register')
  registerDevice(
    @Body() body: { deviceId: string; userId: number; deviceName?: string },
  ) {
    return this.devicesService.register(body);
  }
}
