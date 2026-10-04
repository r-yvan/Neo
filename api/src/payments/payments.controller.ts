import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { PaymentsService } from './payments.service.js';
import {
  ConfirmPaymentDto,
  InitiatePaymentDto,
  PaymentHistoryQueryDto,
  WebhookPaymentDto,
  WithdrawDto,
} from './dto/payment.dto.js';
import { CurrentUser } from '../common/decorators/current-user.decorator.js';
import { Public } from '../common/decorators/public.decorator.js';

@ApiTags('Payments')
@Controller('payments')
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  @Post('initiate')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Initiate mobile money payment for a booking' })
  initiate(
    @CurrentUser('id') userId: string,
    @Body() dto: InitiatePaymentDto,
  ) {
    return this.paymentsService.initiate(userId, dto);
  }

  @Post('confirm')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Confirm mock payment' })
  confirm(
    @CurrentUser('id') userId: string,
    @Body() dto: ConfirmPaymentDto,
  ) {
    return this.paymentsService.confirm(userId, dto);
  }

  @Get('history')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Payment transaction history' })
  history(
    @CurrentUser('id') userId: string,
    @Query() query: PaymentHistoryQueryDto,
  ) {
    return this.paymentsService.history(userId, query);
  }

  @Get('earnings/breakdown')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Owner earnings breakdown' })
  earningsBreakdown(@CurrentUser('id') userId: string) {
    return this.paymentsService.earningsBreakdown(userId);
  }

  @Get('earnings')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Total owner earnings from payouts' })
  earnings(@CurrentUser('id') userId: string) {
    return this.paymentsService.earnings(userId);
  }

  @Post('withdraw')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Request withdrawal to mobile money' })
  withdraw(
    @CurrentUser('id') userId: string,
    @Body() dto: WithdrawDto,
  ) {
    return this.paymentsService.withdraw(userId, dto);
  }

  @Get('withdrawals')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'List withdrawal requests' })
  withdrawals(
    @CurrentUser('id') userId: string,
    @Query() query: PaymentHistoryQueryDto,
  ) {
    return this.paymentsService.listWithdrawals(userId, query);
  }

  @Public()
  @Post('webhook/momo')
  @ApiOperation({ summary: 'MTN MoMo payment webhook (placeholder)' })
  webhookMomo(@Body() dto: WebhookPaymentDto) {
    return this.paymentsService.webhookMomo(dto);
  }

  @Public()
  @Post('webhook/airtel')
  @ApiOperation({ summary: 'Airtel Money payment webhook (placeholder)' })
  webhookAirtel(@Body() dto: WebhookPaymentDto) {
    return this.paymentsService.webhookAirtel(dto);
  }
}
