import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth, AuthedRequest } from '../middleware/requireAuth';

const router = Router();
router.use(requireAuth);

const MAX_ITEMS = 20;

router.get(
  '/',
  asyncHandler(async (req: AuthedRequest, res) => {
    const items = await prisma.recentlyViewedItem.findMany({
      where: { userId: req.userId },
      include: { product: true },
      orderBy: { viewedAt: 'desc' },
      take: MAX_ITEMS,
    });
    res.json(items.map((i) => ({ ...i.product, colors: JSON.parse(i.product.colors) })));
  })
);

router.post(
  '/:productId',
  asyncHandler(async (req: AuthedRequest, res) => {
    const product = await prisma.product.findUnique({ where: { id: req.params.productId } });
    if (!product) return res.status(404).json({ error: '상품을 찾을 수 없습니다.' });

    await prisma.recentlyViewedItem.upsert({
      where: { userId_productId: { userId: req.userId!, productId: product.id } },
      create: { userId: req.userId!, productId: product.id },
      update: { viewedAt: new Date() },
    });

    const items = await prisma.recentlyViewedItem.findMany({
      where: { userId: req.userId },
      orderBy: { viewedAt: 'desc' },
    });
    if (items.length > MAX_ITEMS) {
      const toRemove = items.slice(MAX_ITEMS).map((i) => i.id);
      await prisma.recentlyViewedItem.deleteMany({ where: { id: { in: toRemove } } });
    }

    res.status(201).json({ ok: true });
  })
);

export default router;
