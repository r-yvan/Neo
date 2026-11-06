import {
  BadRequestException,
  Controller,
  Post,
  Req,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { Request } from 'express';
import { randomUUID } from 'node:crypto';
import { mkdirSync } from 'node:fs';
import { extname, resolve } from 'node:path';
import { diskStorage } from 'multer';

/** Minimal shape of a file stored by multer's disk storage. */
interface StoredFile {
  filename: string;
  originalname: string;
  mimetype: string;
  size: number;
}

export const uploadDir = (): string =>
  resolve(process.cwd(), process.env.UPLOAD_DIR || 'uploads');

const ALLOWED = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/heic',
  'image/heif',
]);

const EXT_FOR: Record<string, string> = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'image/webp': '.webp',
  'image/heic': '.heic',
  'image/heif': '.heif',
};

@ApiTags('Uploads')
@ApiBearerAuth()
@Controller('uploads')
export class UploadsController {
  @Post()
  @ApiOperation({
    summary:
      'Upload one image (equipment photo, avatar, National ID). Returns its public URL.',
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: { file: { type: 'string', format: 'binary' } },
      required: ['file'],
    },
  })
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (_req, _file, cb) => {
          const dir = uploadDir();
          mkdirSync(dir, { recursive: true });
          cb(null, dir);
        },
        filename: (_req, file, cb) => {
          const ext =
            EXT_FOR[file.mimetype] ||
            extname(file.originalname).toLowerCase() ||
            '.jpg';
          cb(null, `${randomUUID()}${ext}`);
        },
      }),
      limits: {
        fileSize: Number(process.env.MAX_FILE_SIZE_MB || 5) * 1024 * 1024,
      },
      fileFilter: (_req, file, cb) => {
        // Some Android pickers send application/octet-stream; accept by extension.
        const byExt = /\.(jpe?g|png|webp|heic|heif)$/i.test(file.originalname);
        if (ALLOWED.has(file.mimetype) || byExt) {
          cb(null, true);
        } else {
          cb(
            new BadRequestException('Only JPEG, PNG, WEBP or HEIC images are allowed'),
            false,
          );
        }
      },
    }),
  )
  upload(@UploadedFile() file: StoredFile | undefined, @Req() req: Request) {
    if (!file) {
      throw new BadRequestException('Attach an image in the "file" field');
    }
    const path = `/uploads/${file.filename}`;
    const host = req.get('host');
    return {
      url: `${req.protocol}://${host}${path}`,
      path,
      size: file.size,
      mimeType: file.mimetype,
    };
  }
}
