import { Injectable } from '@nestjs/common';
import { EquipmentCategory } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class SystemService {
  constructor(private readonly prisma: PrismaService) {}

  async getHealth() {
    let dbStatus = 'healthy';
    try {
      await this.prisma.$queryRaw`SELECT 1`;
    } catch {
      dbStatus = 'degraded';
    }

    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.floor(process.uptime()),
      database: dbStatus,
      environment: process.env.NODE_ENV || 'development',
      version: '1.0.0',
    };
  }

  getConfig() {
    return {
      appName: 'Neo Event Equipment Rental',
      country: 'Rwanda',
      currency: 'RWF',
      commissionRate: 0.10, // 10% commission on rental
      boostPricingTiers: [
        { durationDays: 1, price: 2000, label: '1 Day Boost' },
        { durationDays: 3, price: 5000, label: '3 Days Boost' },
        { durationDays: 7, price: 10000, label: '7 Days Boost' },
      ],
      paymentMethods: [
        { id: 'MTN_MOMO', name: 'MTN Mobile Money', icon: 'momo' },
        { id: 'AIRTEL_MONEY', name: 'Airtel Money', icon: 'airtel' },
        { id: 'CARD', name: 'Bank Card / Visa / Mastercard', icon: 'card' },
      ],
      support: {
        phone: '+250 788 123 456',
        whatsapp: '+250 788 123 456',
        email: 'support@neoevents.rw',
      },
    };
  }

  getLocations() {
    return [
      {
        province: 'Kigali City',
        districts: ['Gasabo', 'Kicukiro', 'Nyarugenge'],
      },
      {
        province: 'Northern Province',
        districts: ['Burera', 'Gakenke', 'Gicumbi', 'Musanze', 'Rulindo'],
      },
      {
        province: 'Southern Province',
        districts: ['Gisagara', 'Huye', 'Kamonyi', 'Muhanga', 'Nyamagabe', 'Nyanza', 'Nyaruguru', 'Ruhango'],
      },
      {
        province: 'Eastern Province',
        districts: ['Bugesera', 'Gatsibo', 'Kayonza', 'Kirehe', 'Ngoma', 'Nyagatare', 'Rwamagana'],
      },
      {
        province: 'Western Province',
        districts: ['Karongi', 'Ngororero', 'Nyabihu', 'Nyamasheke', 'Rubavu', 'Rusizi', 'Rutsiro'],
      },
    ];
  }

  getCategories() {
    return [
      {
        code: EquipmentCategory.CHAIRS,
        name: 'Chairs & Seating',
        description: 'Plastic chairs, VIP banquet chairs, conference chairs, and sofas',
      },
      {
        code: EquipmentCategory.TABLES,
        name: 'Tables & High Tables',
        description: 'Round wedding tables, buffet rectangular tables, cocktail high tops',
      },
      {
        code: EquipmentCategory.TENTS,
        name: 'Tents & Canopies',
        description: 'Pagoda tents, dome marquee tents, gazebos, heavy-duty wedding tents',
      },
      {
        code: EquipmentCategory.SPEAKERS,
        name: 'Sound & Audio Systems',
        description: 'PA systems, wireless microphones, subwoofers, DJ mixers, audio cables',
      },
      {
        code: EquipmentCategory.LIGHTS,
        name: 'Lighting & Stage FX',
        description: 'LED wash lights, moving heads, spotlights, mood fairy lights, smoke machines',
      },
      {
        code: EquipmentCategory.COOLERS,
        name: 'Coolers & Catering Equipment',
        description: 'Chafing dishes, ice chests, beverage coolers, catering warmers',
      },
      {
        code: EquipmentCategory.GENERATORS,
        name: 'Power & Generators',
        description: 'Silent diesel and petrol power generators, heavy-duty extension reels',
      },
      {
        code: EquipmentCategory.DECORATIONS,
        name: 'Decorations & Backdrops',
        description: 'Photo backdrops, red carpets, centerpieces, archways, table runners',
      },
      {
        code: EquipmentCategory.OTHER,
        name: 'Other Event Supplies',
        description: 'Projectors, podiums, stanchions with velvet ropes, and miscellaneous items',
      },
    ];
  }
}
