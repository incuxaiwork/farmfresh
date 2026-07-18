import { Controller, Post, UseGuards, Req, Body, UseInterceptors, UploadedFile, ParseFilePipe, MaxFileSizeValidator, FileTypeValidator, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { RolesGuard } from '../guards/roles.guard';
import { CurrentUser, CurrentUserPayload } from '../decorators/current-user.decorator';
import { Roles } from '../decorators/roles.decorator';
import { Public } from '../decorators/public.decorator';
import { SuccessResponseDto } from '../dto/api-response.dto';
import { ProfileImageUploadDto } from '../dto/profile-image-upload.dto';
import { CloudinaryService } from '../services/cloudinary.service';
import { AuthService } from '../../auth/auth.service';

@Controller('upload')
@ApiTags('File Upload')
@UseGuards(RolesGuard)
export class UploadController {
  constructor(
    private readonly cloudinaryService: CloudinaryService,
    private readonly authService: AuthService,
  ) {}

  @Post('profile-picture')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Upload or replace profile picture' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({ type: ProfileImageUploadDto })
  @UseInterceptors(FileInterceptor('image'))
  async uploadProfilePicture(
    @CurrentUser() user: CurrentUserPayload,
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSizeKilobytes: 2048 }), // 2MB
          new FileTypeValidator({ fileType: /\.(jpg|jpeg|png|webp)$/i }),
        ],
      }),
    )
    file: Express.Multer.File,
  ) {
    if (!this.cloudinaryService.isConfigured()) {
      return new SuccessResponseDto('Cloudinary is not configured. Profile picture upload is currently unavailable.', { success: false });
    }

    try {
      // Upload to Cloudinary
      const uploadResult = await this.cloudinaryService.uploadImage(file.buffer, 'farmfresh-profile-pictures', [
        { width: 512, height: 512, crop: 'fill', gravity: 'face' },
        { quality: 'auto' },
      ]);

      const userProfile = await this.authService.getProfile(user.id);
      const oldAvatar = userProfile.avatar;

      // Update user profile with new avatar URL
      const updatedUser = await this.authService.updateProfile(user.id, undefined, undefined, undefined, undefined, uploadResult.secure_url);

      // If there's an old avatar from Cloudinary (same domain), delete it
      if (oldAvatar && oldAvatar.includes('res.cloudinary.com') && oldAvatar.includes('/farmfresh-profile-pictures/')) {
        const oldPublicId = oldAvatar.split('/upload/')[1]?.split('.')[0];
        if (oldPublicId) {
          await this.cloudinaryService.deleteImage(oldPublicId);
        }
      }

      return new SuccessResponseDto('Profile picture uploaded successfully', {
        imageUrl: uploadResult.secure_url,
        publicId: uploadResult.public_id,
        format: uploadResult.format,
        resourceType: uploadResult.resource_type,
      });
    } catch (error) {
      throw error;
    }
  }

  @Post('profile-picture/remove')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Remove profile picture' })
  @ApiBody({ type: ProfileImageUploadDto })
  @HttpCode(HttpStatus.OK)
  async removeProfilePicture(
    @CurrentUser() user: CurrentUserPayload,
    @Body() dto: ProfileImageUploadDto,
  ) {
    if (!this.cloudinaryService.isConfigured()) {
      return new SuccessResponseDto('Cloudinary is not configured. Profile picture removal is currently unavailable.', { success: false });
    }

    const userProfile = await this.authService.getProfile(user.id);
    const currentAvatar = userProfile.avatar;

    if (!currentAvatar || !currentAvatar.includes('res.cloudinary.com')) {
      return new SuccessResponseDto('No profile picture found to remove', { success: false });
    }

    try {
      // Extract public_id from the Cloudinary URL
      const urlPattern = /res\.cloudinary\.com\/([^\/]+)\/image\/upload\/v\d+\/([^\/\.]+)\.(jpg|jpeg|png|webp)/;
      const match = currentAvatar.match(urlPattern);
      
      if (match) {
        const publicId = match[2];
        await this.cloudinaryService.deleteImage(publicId);
      }

      // Update user profile to remove avatar
      const updatedUser = await this.authService.updateProfile(user.id, undefined, undefined, undefined, undefined, undefined);

      return new SuccessResponseDto('Profile picture removed successfully', {
        removed: true,
        avatar: null,
      });
    } catch (error) {
      throw error;
    }
  }
}