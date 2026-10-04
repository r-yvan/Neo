import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { UsersService } from './users.service.js';
import {
  AddRoleDto,
  ChangePasswordDto,
  UpdateProfileDto,
  UploadAvatarDto,
  VerifyNationalIdDto,
} from './dto/users.dto.js';
import { Public } from '../common/decorators/public.decorator.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { PaginationDto } from '../common/dto/pagination.dto.js';

@ApiTags('Users')
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('me')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile' })
  getMe(@CurrentUser('id') userId: string) {
    return this.usersService.getMe(userId);
  }

  @Patch('me')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update current user profile' })
  updateMe(@CurrentUser('id') userId: string, @Body() dto: UpdateProfileDto) {
    return this.usersService.updateMe(userId, dto);
  }

  @Post('me/avatar')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Set profile avatar URL' })
  uploadAvatar(
    @CurrentUser('id') userId: string,
    @Body() dto: UploadAvatarDto,
  ) {
    return this.usersService.uploadAvatar(userId, dto.url);
  }

  @Delete('me/avatar')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remove profile avatar' })
  removeAvatar(@CurrentUser('id') userId: string) {
    return this.usersService.removeAvatar(userId);
  }

  @Post('me/change-password')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Change account password' })
  changePassword(
    @CurrentUser('id') userId: string,
    @Body() dto: ChangePasswordDto,
  ) {
    return this.usersService.changePassword(userId, dto);
  }

  @Patch('me/role')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add OWNER or RENTER role to account' })
  addRole(@CurrentUser('id') userId: string, @Body() dto: AddRoleDto) {
    return this.usersService.addRole(userId, dto);
  }

  @Post('me/verify-national-id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Submit national ID for verification' })
  submitNationalId(
    @CurrentUser('id') userId: string,
    @Body() dto: VerifyNationalIdDto,
  ) {
    return this.usersService.submitNationalId(userId, dto);
  }

  @Public()
  @Get('search')
  @ApiOperation({ summary: 'Search users by name' })
  searchUsers(@Query() query: PaginationDto) {
    return this.usersService.searchUsers(query);
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Get public user profile' })
  getPublicProfile(@Param('id') id: string) {
    return this.usersService.getPublicProfile(id);
  }

  @Public()
  @Get(':id/reviews')
  @ApiOperation({ summary: 'List reviews received by user' })
  getUserReviews(@Param('id') id: string, @Query() query: PaginationDto) {
    return this.usersService.getUserReviews(id, query);
  }

  @Public()
  @Get(':id/equipment')
  @ApiOperation({ summary: 'List equipment owned by user' })
  getUserEquipment(@Param('id') id: string, @Query() query: PaginationDto) {
    return this.usersService.getUserEquipment(id, query);
  }
}
