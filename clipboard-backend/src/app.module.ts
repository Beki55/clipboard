import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.modue copy';
import { AuthModule } from './auth/auth.module';
import { ClipboardModule } from './clipboard/clipboard.module';
import { DevicesModule } from './devices/devices.module';

@Module({
  imports: [PrismaModule, AuthModule, ClipboardModule, DevicesModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
