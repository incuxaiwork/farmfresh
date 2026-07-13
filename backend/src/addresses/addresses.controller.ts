import { Controller, Get, Post, Patch, Delete, Param, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { RolesGuard } from '../common/guards/roles.guard';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';
import { AddressesService } from './addresses.service';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateAddressDto } from './dto/update-address.dto';
import { SuccessResponseDto } from '../common/dto/api-response.dto';

@ApiTags('Addresses')
@Controller('addresses')
@UseGuards(AuthGuard('jwt'), RolesGuard)
@ApiBearerAuth('JWT-auth')
export class AddressesController {
  constructor(private readonly addressesService: AddressesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all addresses of current user' })
  async findAll(@CurrentUser() user: CurrentUserPayload) {
    const data = await this.addressesService.findAll(user.id);
    return new SuccessResponseDto('Addresses loaded successfully', data);
  }

  @Post()
  @ApiOperation({ summary: 'Add a new address for current user' })
  async create(@CurrentUser() user: CurrentUserPayload, @Body() dto: CreateAddressDto) {
    const data = await this.addressesService.create(user.id, dto);
    return new SuccessResponseDto('Address created successfully', data);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update an existing address of current user' })
  async update(
    @CurrentUser() user: CurrentUserPayload,
    @Param('id') id: string,
    @Body() dto: UpdateAddressDto,
  ) {
    const data = await this.addressesService.update(id, user.id, dto);
    return new SuccessResponseDto('Address updated successfully', data);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete an address of current user' })
  async remove(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    const data = await this.addressesService.remove(id, user.id);
    return new SuccessResponseDto('Address deleted successfully', data);
  }
}
