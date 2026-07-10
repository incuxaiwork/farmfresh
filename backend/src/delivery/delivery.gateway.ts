import { WebSocketGateway, WebSocketServer, SubscribeMessage, MessageBody, ConnectedSocket } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: 'tracking',
})
export class DeliveryGateway {
  @WebSocketServer()
  server: Server;

  // Real-time location push connection room joiner
  @SubscribeMessage('joinDeliveryTrack')
  handleJoinRoom(
    @MessageBody() data: { orderId: string },
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`order-${data.orderId}`);
    return { success: true, message: `Joined tracking room order-${data.orderId}` };
  }

  // Broadcast driver position update to client room
  broadcastLocation(orderId: string, location: { lat: number; lng: number; driverId: string }) {
    this.server.to(`order-${orderId}`).emit('locationUpdated', location);
  }
}
