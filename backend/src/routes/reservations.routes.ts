import { Router } from 'express';
import { z } from 'zod';
import { v4 as uuidv4 } from 'uuid';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth, AuthedRequest } from '../middleware/requireAuth';

const router = Router();
router.use(requireAuth);

router.get(
  '/',
  asyncHandler(async (req: AuthedRequest, res) => {
    const reservations = await prisma.reservation.findMany({
      where: { userId: req.userId },
      orderBy: { createdAt: 'desc' },
    });
    res.json(reservations);
  })
);

// 매장 체크인 화면의 "QR코드로 체크인"에서 사용할 가장 최근 예약
router.get(
  '/upcoming',
  asyncHandler(async (req: AuthedRequest, res) => {
    const reservation = await prisma.reservation.findFirst({
      where: { userId: req.userId, status: 'upcoming' },
      orderBy: { createdAt: 'desc' },
    });
    res.json(reservation ?? null);
  })
);

const createSchema = z.object({
  storeId: z.string(),
  storeName: z.string(),
  date: z.string(), // 예: '2026년 8월 24일'
  time: z.string(), // 예: '오후 3:00'
  itemCount: z.number().int().min(0).default(0),
});

router.post(
  '/',
  asyncHandler(async (req: AuthedRequest, res) => {
    const { storeId, storeName, date, time, itemCount } = createSchema.parse(req.body);
    const code = `MIRA-${Date.now()}-${uuidv4().slice(0, 4).toUpperCase()}`;
    const reservation = await prisma.reservation.create({
      data: { userId: req.userId!, storeId, storeName, date, time, itemCount, code },
    });
    res.status(201).json(reservation);
  })
);

router.post(
  '/:id/cancel',
  asyncHandler(async (req: AuthedRequest, res) => {
    const reservation = await prisma.reservation.findFirst({ where: { id: req.params.id, userId: req.userId } });
    if (!reservation) return res.status(404).json({ error: '예약을 찾을 수 없습니다.' });
    const updated = await prisma.reservation.update({ where: { id: reservation.id }, data: { status: 'cancelled' } });
    res.json(updated);
  })
);

export default router;
