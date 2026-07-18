import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { v2 as cloudinary } from 'cloudinary';
import * as streamifier from 'streamifier';

export interface CloudinaryUploadResult {
  public_id: string;
  secure_url: string;
  format: string;
  resource_type: string;
}

@Injectable()
export class CloudinaryService {
  private cloudinaryProvider?: any;

  constructor(private configService: ConfigService) {
    const cloudName = this.configService.get<string>('cloudinary.cloudName');
    const apiKey = this.configService.get<string>('cloudinary.apiKey');
    const apiSecret = this.configService.get<string>('cloudinary.apiSecret');

    if (cloudName && apiKey && apiSecret) {
      this.cloudinaryProvider = cloudinary.config({
        cloud_name: cloudName,
        api_key: apiKey,
        api_secret: apiSecret,
        secure: true,
      });
    }
  }

  isConfigured(): boolean {
    return !!this.cloudinaryProvider;
  }

  async uploadImage(
    fileBuffer: Buffer,
    folder: string = 'farmfresh-profile-pictures',
    transformation?: any,
  ): Promise<CloudinaryUploadResult> {
    if (!this.isConfigured()) {
      throw new BadRequestException('Cloudinary is not configured. Please check cloud_name, api_key, and api_secret in environment variables.');
    }

    try {
      const uploadPromise = new Promise<CloudinaryUploadResult>((resolve, reject) => {
        const uploadStream = cloudinary().uploader.upload_stream(
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
          (error, result) => {
            if (error) {
              reject(error);
            } else {
              resolve(result as CloudinaryUploadResult);
            }
          }
        );

        streamifier.createReadStream(fileBuffer).pipe(uploadStream);
      });

      const result = await uploadPromise;
      return result;
    } catch (error) {
      throw new BadRequestException(`Failed to upload image to Cloudinary: ${(error as Error).message}`);
    }
  }

  async deleteImage(publicId: string): Promise<any> {
    if (!this.isConfigured()) {
      throw new BadRequestException('Cloudinary is not configured');
    }

    try {
      const result = await cloudinary().uploader.destroy(publicId);
      return result;
    } catch (error) {
      throw new BadRequestException(`Failed to delete image from Cloudinary: ${(error as Error).message}`);
    }
  }
}
