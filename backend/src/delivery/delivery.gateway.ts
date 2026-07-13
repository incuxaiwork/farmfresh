import { WebSocketGateway, WebSocketServer, SubscribeMessage, MessageBody, ConnectedSocket } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class DeliveryGateway {
  @WebSocketServer()
  server: Server;

  // Handle join room for order tracking
  @SubscribeMessage('join:order')
  handleJoinOrder(
    @MessageBody() data: any,
    @ConnectedSocket() client: Socket,
  ) {
    const orderId = typeof data === 'string' ? data : data?.orderId;
    if (orderId) {
      client.join(`order-${orderId}`);
      console.log(`[Socket] Client joined room: order-${orderId}`);
      return { success: true, message: `Joined tracking room order-${orderId}` };
    }
  }

  // Supporting legacy room joiner
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
    console.log(`[Socket] Broadcasting location to room order-${orderId}:`, location);
    this.server.to(`order-${orderId}`).emit('delivery:location', {
      latitude: location.lat,
      longitude: location.lng,
      driverId: location.driverId,
      orderId,
    });
  }
}
