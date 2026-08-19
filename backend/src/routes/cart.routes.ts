import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth, AuthedRequest } from '../middleware/requireAuth';

const router = Router();
router.use(requireAuth);

function serializeItem(item: any) {
  return {
    id: item.id,
    product: { ...item.product, colors: JSON.parse(item.product.colors) },
    selectedColor: item.selectedColor,
    quantity: item.quantity,
    subtotal: item.product.price * item.quantity,
  };
}

router.get(
  '/',
  asyncHandler(async (req: AuthedRequest, res) => {
    const items = await prisma.cartItem.findMany({
      where: { userId: req.userId },
      include: { product: true },
    });
    const serialized = items.map(serializeItem);
    res.json({
      items: serialized,
      totalCount: serialized.reduce((s, i) => s + i.quantity, 0),
      totalPrice: serialized.reduce((s, i) => s + i.subtotal, 0),
    });
  })
);

const addSchema = z.object({
  productId: z.string(),
  color: z.string().optional(),
  quantity: z.number().int().min(1).default(1),
});

router.post(
  '/items',
  asyncHandler(async (req: AuthedRequest, res) => {
    const { productId, color, quantity } = addSchema.parse(req.body);
    const product = await prisma.product.findUnique({ where: { id: productId } });
    if (!product) return res.status(404).json({ error: '상품을 찾을 수 없습니다.' });

    const existing = await prisma.cartItem.findFirst({
      where: { userId: req.userId, productId, selectedColor: color ?? null },
    });

    const item = existing
      ? await prisma.cartItem.update({
          where: { id: existing.id },
          data: { quantity: existing.quantity + quantity },
          include: { product: true },
        })
      : await prisma.cartItem.create({
          data: { userId: req.userId!, productId, selectedColor: color, quantity },
          include: { product: true },
        });

    res.status(201).json(serializeItem(item));
  })
);

const updateSchema = z.object({ quantity: z.number().int().min(1) });

router.patch(
  '/items/:itemId',
  asyncHandler(async (req: AuthedRequest, res) => {
    const { quantity } = updateSchema.parse(req.body);
    const item = await prisma.cartItem.findFirst({ where: { id: req.params.itemId, userId: req.userId } });
    if (!item) return res.status(404).json({ error: '장바구니 항목을 찾을 수 없습니다.' });
    const updated = await prisma.cartItem.update({
      where: { id: item.id },
      data: { quantity },
      include: { product: true },
    });
    res.json(serializeItem(updated));
  })
);

router.delete(
  '/items/:itemId',
  asyncHandler(async (req: AuthedRequest, res) => {
    const item = await prisma.cartItem.findFirst({ where: { id: req.params.itemId, userId: req.userId } });
    if (!item) return res.status(404).json({ error: '장바구니 항목을 찾을 수 없습니다.' });
    await prisma.cartItem.delete({ where: { id: item.id } });
    res.status(204).send();
  })
);

router.delete(
  '/',
  asyncHandler(async (req: AuthedRequest, res) => {
    await prisma.cartItem.deleteMany({ where: { userId: req.userId } });
    res.status(204).send();
  })
);

export default router;
