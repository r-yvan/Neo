import { describe, it, expect, vi } from 'vitest';
import { SystemService } from './system.service.js';
import { PrismaService } from '../prisma/prisma.service.js';

describe('SystemService', () => {
  it('should return config including Rwanda currency and commission rate', () => {
    const mockPrisma = {} as PrismaService;
    const service = new SystemService(mockPrisma);
    const config = service.getConfig();

    expect(config.currency).toBe('RWF');
    expect(config.commissionRate).toBe(0.1);
    expect(config.paymentMethods.length).toBeGreaterThan(0);
  });

  it('should return supported provinces and districts', () => {
    const mockPrisma = {} as PrismaService;
    const service = new SystemService(mockPrisma);
    const locations = service.getLocations();

    expect(locations).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          province: 'Kigali City',
          districts: expect.arrayContaining(['Gasabo', 'Kicukiro', 'Nyarugenge']),
        }),
      ]),
    );
  });
});
