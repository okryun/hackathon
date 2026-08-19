import { Router } from 'express';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth, AuthedRequest } from '../middleware/requireAuth';

const router = Router();
router.use(requireAuth);

router.get(
  '/',
  asyncHandler(async (req: AuthedRequest, res) => {
    const items = await prisma.wishlistItem.findMany({
      where: { userId: req.userId },
      include: { product: true },
      orderBy: { createdAt: 'desc' },
    });
    res.json(items.map((i) => ({ ...i.product, colors: JSON.parse(i.product.colors) })));
  })
);

router.post(
  '/:productId',
  asyncHandler(async (req: AuthedRequest, res) => {
    const product = await prisma.product.findUnique({ where: { id: req.params.productId } });
    if (!product) return res.status(404).json({ error: '상품을 찾을 수 없습니다.' });
    await prisma.wishlistItem.upsert({
      where: { userId_productId: { userId: req.userId!, productId: product.id } },
      create: { userId: req.userId!, productId: product.id },
      update: {},
    });
    res.status(201).json({ ok: true });
  })
);

router.delete(
  '/:productId',
  asyncHandler(async (req: AuthedRequest, res) => {
    await prisma.wishlistItem.deleteMany({ where: { userId: req.userId, productId: req.params.productId } });
    res.status(204).send();
  })
);

export default router;
