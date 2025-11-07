import { Logger } from '@nestjs/common';
import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { PrismaService } from '../prisma/prisma.service';

@WebSocketGateway({
  cors: { origin: '*' },
})
export class ClipboardGateway {
  private readonly logger = new Logger(ClipboardGateway.name);
  @WebSocketServer()
  server: Server;

  constructor(private prisma: PrismaService) {}

  async handleConnection(client: Socket) {
    const { userId, deviceId } = client.handshake.query as {
      userId?: string;
      deviceId?: string;
    };
    if (!userId) {
      this.logger.warn(
        `Client ${client.id} attempted to connect without userId. Disconnecting.`,
      );
      return client.disconnect();
    }

    client.join(`user-${userId}`);
    this.logger.log(
      `Client connected: socketId=${client.id} userId=${userId} deviceId=${deviceId ?? 'unknown'}`,
    );
  }

  @SubscribeMessage('clipboard:update')
  async handleClipboardUpdate(
    @MessageBody() data: { userId: number; deviceId: string; content: string },
    @ConnectedSocket() client: Socket,
  ) {
    this.logger.log(
      `Clipboard update received from socketId=${client.id} userId=${data.userId} deviceId=${data.deviceId} contentLength=${data.content?.length ?? 0}`,
    );

    await this.prisma.clipboardItem.create({
      data: {
        userId: data.userId,
        deviceId: data.deviceId,
        content: data.content,
      },
    });

    this.logger.log(
      `Clipboard data stored and broadcasting to room user-${data.userId}`,
    );

    client.to(`user-${data.userId}`).emit('clipboard:receive', data.content);
  }
}
