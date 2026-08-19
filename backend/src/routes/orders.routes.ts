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
    const orders = await prisma.order.findMany({
      where: { userId: req.userId },
      orderBy: { orderedAt: 'desc' },
      include: { items: true },
    });
    res.json(orders);
  })
);

const directOrderSchema = z.object({
  productId: z.string(),
  color: z.string().optional(),
  quantity: z.number().int().min(1).default(1),
});

// "바로구매": productId가 오면 장바구니와 무관하게 상품 하나만 바로 주문한다.
router.post(
  '/',
  asyncHandler(async (req: AuthedRequest, res) => {
    if (req.body && req.body.productId) {
      const { productId, color, quantity } = directOrderSchema.parse(req.body);
      const product = await prisma.product.findUnique({ where: { id: productId } });
      if (!product) return res.status(404).json({ error: '상품을 찾을 수 없습니다.' });

      const totalPrice = product.price * quantity;
      const productSummary = `${product.name}${color ? ` (${color})` : ''}${quantity > 1 ? ` 외 ${quantity - 1}개` : ''}`;
      const orderNumber = `ORD-${Date.now()}-${uuidv4().slice(0, 6).toUpperCase()}`;

      const order = await prisma.order.create({
        data: {
          orderNumber,
          userId: req.userId!,
          productSummary,
          totalPrice,
          items: {
            create: [
              {
                productId: product.id,
                productName: product.name,
                selectedColor: color,
                quantity,
                price: product.price,
              },
            ],
          },
        },
        include: { items: true },
      });

      return res.status(201).json(order);
    }

    // 장바구니 내용을 그대로 주문으로 전환하고 장바구니를 비운다 (결제 화면의 "주문하기").
    const cartItems = await prisma.cartItem.findMany({
      where: { userId: req.userId },
      include: { product: true },
    });
    if (cartItems.length === 0) {
      return res.status(400).json({ error: '장바구니가 비어 있습니다.' });
    }

    const totalPrice = cartItems.reduce((s, i) => s + i.product.price * i.quantity, 0);
    const productSummary =
      cartItems.length === 1 ? cartItems[0].product.name : `${cartItems[0].product.name} 외 ${cartItems.length - 1}건`;
    const orderNumber = `ORD-${Date.now()}-${uuidv4().slice(0, 6).toUpperCase()}`;

    const order = await prisma.order.create({
      data: {
        orderNumber,
        userId: req.userId!,
        productSummary,
        totalPrice,
        items: {
          create: cartItems.map((item) => ({
            productId: item.productId,
            productName: item.product.name,
            selectedColor: item.selectedColor,
            quantity: item.quantity,
            price: item.product.price,
          })),
        },
      },
      include: { items: true },
    });

    await prisma.cartItem.deleteMany({ where: { userId: req.userId } });

    res.status(201).json(order);
  })
);

export default router;
