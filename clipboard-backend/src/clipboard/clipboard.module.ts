import { Module } from '@nestjs/common';
import { ClipboardGateway } from './clipboard.gateway';
import { PrismaModule } from 'src/prisma/prisma.modue copy';

@Module({
  imports: [PrismaModule],
  providers: [ClipboardGateway],
})
export class ClipboardModule {}
