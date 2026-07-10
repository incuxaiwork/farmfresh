import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { CartService } from './cart.service';
import { AddCartItemDto } from './dto/add-cart-item.dto';
import { UpdateCartItemDto } from './dto/update-cart-item.dto';
import { SuccessResponseDto } from '../common/dto/api-response.dto';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';

@ApiTags('Shopping Cart')
@Controller('cart')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('JWT-auth')
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Get()
  @Roles('CUSTOMER')
  @ApiOperation({ summary: 'Retrieve active shopping cart containing selected products items (Customer Only)' })
  async getCart(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.cartService.getCart(user.id);
    return new SuccessResponseDto('Cart loaded successfully', data);
  }

  @Post('items')
  @Roles('CUSTOMER')
  @ApiOperation({ summary: 'Add product item to active shopping cart (Customer Only)' })
  @ApiResponse({ status: 201, description: 'Item added to cart successfully' })
  async addItem(@CurrentUser() user: CurrentUserPayload, @Body() dto: AddCartItemDto) {
    const data = await this.cartService.addItem(user.id, dto);
    return new SuccessResponseDto('Item added to cart successfully', data);
  }

  @Patch('items/:id')
  @Roles('CUSTOMER')
  @ApiOperation({ summary: 'Update cart item quantity volume (Customer Only)' })
  async updateItem(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body() dto: UpdateCartItemDto,
  ) {
    const data = await this.cartService.updateItem(user.id, id, dto);
    return new SuccessResponseDto('Cart item updated successfully', data);
  }

  @Delete('items/:id')
  @Roles('CUSTOMER')
  @ApiOperation({ summary: 'Remove a specific product item from cart (Customer Only)' })
  async removeItem(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.cartService.removeItem(user.id, id);
    return new SuccessResponseDto('Item removed from cart successfully', data);
  }

  @Delete('clear')
  @Roles('CUSTOMER')
  @ApiOperation({ summary: 'Remove all items and clear active cart (Customer Only)' })
  async clearCart(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.cartService.clearCart(user.id);
    return new SuccessResponseDto('Cart cleared successfully', data);
  }

  @Get('summary')
  @Roles('CUSTOMER')
  @ApiOperation({ summary: 'Retrieve active cart pricing totals summary (Customer Only)' })
  async getCartSummary(@CurrentUser() user: CurrentUserPayload) {
    const cart = await this.cartService.getCart(user.id);
    const data = {
      subtotal: cart.subtotal,
      discount: cart.discount,
      tax: cart.tax,
      deliveryCharge: cart.deliveryCharge,
      grandTotal: cart.grandTotal,
    };
    return new SuccessResponseDto('Cart summary loaded successfully', data);
  }
}
