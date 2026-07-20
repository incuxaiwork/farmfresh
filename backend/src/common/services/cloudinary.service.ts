import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary } from 'cloudinary';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const streamifier = require('streamifier');

export interface CloudinaryUploadResult {
  public_id: string;
  secure_url: string;
  format: string;
  resource_type: string;
}

@Injectable()
export class CloudinaryService {
  private configured = false;

  constructor(private configService: ConfigService) {
    const cloudName = this.configService.get<string>('cloudinary.cloudName');
    const apiKey = this.configService.get<string>('cloudinary.apiKey');
    const apiSecret = this.configService.get<string>('cloudinary.apiSecret');

    if (cloudName && apiKey && apiSecret) {
      cloudinary.config({
        cloud_name: cloudName,
        api_key: apiKey,
        api_secret: apiSecret,
        secure: true,
      });
      this.configured = true;
    }
  }

  isConfigured(): boolean {
    return this.configured;
  }

  async uploadImage(
    fileBuffer: Buffer,
    folder: string = 'farmfresh-profile-pictures',
    transformation?: any,
  ): Promise<CloudinaryUploadResult> {
    if (!this.isConfigured()) {
      throw new BadRequestException('Cloudinary is not configured.');
    }

    try {
      const uploadPromise = new Promise<CloudinaryUploadResult>((resolve, reject) => {
        const uploadStream = cloudinary.uploader.upload_stream(
          {
            folder,
            resource_type: 'image',
            format: 'auto',
            transformation: transformation || [
              { width: 1200, height: 1200, crop: 'limit' },
              { quality: 'auto' },
              { fetch_format: 'auto' },
            ],
          },
          (error: any, result: any) => {
            if (error) {
              reject(error);
            } else {
              resolve(result as CloudinaryUploadResult);
            }
          },
        );

        streamifier.createReadStream(fileBuffer).pipe(uploadStream);
      });

      return await uploadPromise;
    } catch (error) {
      throw new BadRequestException(`Failed to upload image to Cloudinary: ${(error as Error).message}`);
    }
  }

  async deleteImage(publicId: string): Promise<any> {
    if (!this.isConfigured()) {
      throw new BadRequestException('Cloudinary is not configured');
    }

    try {
      return await cloudinary.uploader.destroy(publicId);
    } catch (error) {
      throw new BadRequestException(`Failed to delete image from Cloudinary: ${(error as Error).message}`);
    }
  }
}
