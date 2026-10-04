import { PrismaClient, UserRole, EquipmentCategory } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding neo-db...');

  const passwordHash = await bcrypt.hash('Password123!', 10);

  const admin = await prisma.user.upsert({
    where: { phone: '250780000001' },
    update: {},
    create: {
      phone: '250780000001',
      fullName: 'Neo Admin',
      email: 'admin@neo.rw',
      passwordHash,
      roles: [UserRole.ADMIN, UserRole.OWNER, UserRole.RENTER],
      isVerified: true,
      nationalId: '1199900000000001',
      notificationSetting: { create: {} },
    },
  });

  const owner = await prisma.user.upsert({
    where: { phone: '250780000002' },
    update: {},
    create: {
      phone: '250780000002',
      fullName: 'Alice Owner',
      email: 'alice@neo.rw',
      passwordHash,
      roles: [UserRole.OWNER, UserRole.RENTER],
      isVerified: true,
      nationalId: '1199900000000002',
      notificationSetting: { create: {} },
    },
  });

  const renter = await prisma.user.upsert({
    where: { phone: '250780000003' },
    update: {},
    create: {
      phone: '250780000003',
      fullName: 'Bob Renter',
      email: 'bob@neo.rw',
      passwordHash,
      roles: [UserRole.RENTER],
      isVerified: true,
      nationalId: '1199900000000003',
      notificationSetting: { create: {} },
    },
  });

  const existing = await prisma.equipment.count({ where: { ownerId: owner.id } });
  if (existing === 0) {
    await prisma.equipment.createMany({
      data: [
        {
          ownerId: owner.id,
          title: 'White Plastic Chairs (50 pcs)',
          description: 'Clean stackable chairs for weddings and events',
          category: EquipmentCategory.CHAIRS,
          quantity: 50,
          pricePerDay: 15000,
          depositAmount: 5000,
          location: 'Kigali - Nyarugenge',
          latitude: -1.9441,
          longitude: 30.0619,
          images: [],
          isBoosted: true,
          boostedUntil: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        },
        {
          ownerId: owner.id,
          title: 'Round Banquet Tables (10)',
          description: 'Seats 8–10 people each',
          category: EquipmentCategory.TABLES,
          quantity: 10,
          pricePerDay: 20000,
          depositAmount: 8000,
          location: 'Kigali - Gasabo',
          latitude: -1.9355,
          longitude: 30.1086,
          images: [],
        },
        {
          ownerId: owner.id,
          title: 'Party Tent 5x10m',
          description: 'Waterproof tent with side walls',
          category: EquipmentCategory.TENTS,
          quantity: 2,
          pricePerDay: 45000,
          depositAmount: 20000,
          location: 'Kigali - Kicukiro',
          latitude: -1.9706,
          longitude: 30.1044,
          images: [],
        },
      ],
    });
  }

  const locCount = await prisma.location.count();
  if (locCount === 0) {
    await prisma.location.createMany({
      data: [
        { province: 'Kigali', district: 'Nyarugenge', sector: 'Nyarugenge', cell: 'Kiyovu' },
        { province: 'Kigali', district: 'Gasabo', sector: 'Remera', cell: 'Rukiri' },
        { province: 'Kigali', district: 'Kicukiro', sector: 'Gatenga', cell: 'Gatenga' },
        { province: 'Southern', district: 'Huye', sector: 'Ngoma', cell: 'Butare' },
        { province: 'Northern', district: 'Musanze', sector: 'Muhoza', cell: 'Cyabararika' },
      ],
    });
  }

  await prisma.appConfig.upsert({
    where: { key: 'commission_rate' },
    update: { value: '0.10' },
    create: { key: 'commission_rate', value: '0.10' },
  });
  await prisma.appConfig.upsert({
    where: { key: 'boost_fee_rwf' },
    update: { value: '3000' },
    create: { key: 'boost_fee_rwf', value: '3000' },
  });

  console.log('Seed complete:');
  console.log({
    admin: admin.phone,
    owner: owner.phone,
    renter: renter.phone,
    password: 'Password123!',
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
