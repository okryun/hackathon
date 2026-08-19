import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth, AuthedRequest } from '../middleware/requireAuth';

const router = Router();
router.use(requireAuth);

const checkinSchema = z.object({ storeId: z.string(), storeName: z.string() });

// NFC 태그 / QR코드를 인식한 뒤 프론트에서 storeId, storeName을 담아 호출한다.
router.post(
  '/checkin',
  asyncHandler(async (req: AuthedRequest, res) => {
    const { storeId, storeName } = checkinSchema.parse(req.body);

    await prisma.storeCheckin.updateMany({
      where: { userId: req.userId, checkedOutAt: null },
      data: { checkedOutAt: new Date() },
    });

    const checkin = await prisma.storeCheckin.create({
      data: { userId: req.userId!, storeId, storeName },
    });
    res.status(201).json(checkin);
  })
);

router.post(
  '/checkout',
  asyncHandler(async (req: AuthedRequest, res) => {
    await prisma.storeCheckin.updateMany({
      where: { userId: req.userId, checkedOutAt: null },
      data: { checkedOutAt: new Date() },
    });
    res.status(204).send();
  })
);

router.get(
  '/current',
  asyncHandler(async (req: AuthedRequest, res) => {
    const current = await prisma.storeCheckin.findFirst({
      where: { userId: req.userId, checkedOutAt: null },
      orderBy: { checkedInAt: 'desc' },
    });
    res.json(current ?? null);
  })
);

export default router;
