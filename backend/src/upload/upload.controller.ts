import { Controller, Post, UseGuards, Body, UseInterceptors, UploadedFile, ParseFilePipe, MaxFileSizeValidator, FileTypeValidator, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { RolesGuard } from '../common/guards/roles.guard';
import { CurrentUser, CurrentUserPayload } from '../common/decorators/current-user.decorator';
import { CloudinaryService } from '../common/services/cloudinary.service';
import { AuthService } from '../auth/auth.service';

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
  @UseInterceptors(FileInterceptor('image'))
  async uploadProfilePicture(
    @CurrentUser() user: CurrentUserPayload,
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 2048000 }),
          new FileTypeValidator({ fileType: /.(jpg|jpeg|png|webp)$/i }),
        ],
      }),
    )
    file: Express.Multer.File,
  ) {
    if (!this.cloudinaryService.isConfigured()) {
      return { success: false, message: 'Cloudinary is not configured. Profile picture upload is currently unavailable.' };
    }

    const uploadResult = await this.cloudinaryService.uploadImage(file.buffer, 'farmfresh-profile-pictures', [
      { width: 512, height: 512, crop: 'fill', gravity: 'face' },
      { quality: 'auto' },
    ]);

    const userProfile = await this.authService.getProfile(user.id);
    const oldAvatar = userProfile.avatar;

    await this.authService.updateProfile(user.id, undefined, undefined, undefined, undefined, uploadResult.secure_url);

    if (oldAvatar && oldAvatar.includes('res.cloudinary.com') && oldAvatar.includes('/farmfresh-profile-pictures/')) {
      const oldPublicId = oldAvatar.split('/upload/')[1]?.split('.')[0];
      if (oldPublicId) {
        await this.cloudinaryService.deleteImage(oldPublicId);
      }
    }

    return {
      success: true,
      message: 'Profile picture uploaded successfully',
      data: {
        imageUrl: uploadResult.secure_url,
        publicId: uploadResult.public_id,
        format: uploadResult.format,
      },
    };
  }

  @Post('profile-picture/remove')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({ summary: 'Remove profile picture' })
  @HttpCode(HttpStatus.OK)
  async removeProfilePicture(
    @CurrentUser() user: CurrentUserPayload,
  ) {
    if (!this.cloudinaryService.isConfigured()) {
      return { success: false, message: 'Cloudinary is not configured. Profile picture removal is currently unavailable.' };
    }

    const userProfile = await this.authService.getProfile(user.id);
    const currentAvatar = userProfile.avatar;

    if (!currentAvatar || !currentAvatar.includes('res.cloudinary.com')) {
      return { success: false, message: 'No profile picture found to remove' };
    }

    const urlPattern = /res\.cloudinary\.com\/([^\/]+)\/image\/upload\/v\d+\/([^\/\.]+)\.(jpg|jpeg|png|webp)/;
    const match = currentAvatar.match(urlPattern);
    
    if (match) {
      const publicId = match[2];
      await this.cloudinaryService.deleteImage(publicId);
    }

    await this.authService.updateProfile(user.id, undefined, undefined, undefined, undefined, undefined);

    return {
      success: true,
      message: 'Profile picture removed successfully',
      data: { removed: true, avatar: null },
    };
  }
}
