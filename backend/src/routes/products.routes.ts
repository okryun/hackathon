import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../middleware/errorHandler';
import { requireAuth, AuthedRequest } from '../middleware/requireAuth';

const router = Router();

function serializeProduct(p: any) {
  return { ...p, colors: JSON.parse(p.colors) };
}

// GET /products?category=Bag&search=hobo
router.get(
  '/',
  asyncHandler(async (req, res) => {
    const { category, search } = req.query as { category?: string; search?: string };
    const where: any = {};
    if (category && category !== 'All') where.category = category;
    if (search) {
      where.OR = [
        { name: { contains: search } },
        { brand: { contains: search } },
        { category: { contains: search } },
      ];
    }
    const products = await prisma.product.findMany({ where });
    res.json(products.map(serializeProduct));
  })
);

router.get(
  '/categories',
  asyncHandler(async (_req, res) => {
    const products = await prisma.product.findMany({ select: { category: true } });
    const categories = Array.from(new Set(products.map((p) => p.category))).sort();
    res.json(['All', ...categories]);
  })
);

// 리뷰 수 기준 인기 상품 (Flutter MockProductService.fetchPopular와 동일한 로직)
router.get(
  '/popular',
  asyncHandler(async (_req, res) => {
    const products = await prisma.product.findMany({ orderBy: { reviewCount: 'desc' }, take: 6 });
    res.json(products.map(serializeProduct));
  })
);

// 평점 기준 추천 상품 (Flutter MockProductService.fetchRecommended와 동일한 로직)
router.get(
  '/recommended',
  asyncHandler(async (_req, res) => {
    const products = await prisma.product.findMany({ orderBy: { rating: 'desc' }, take: 6 });
    res.json(products.map(serializeProduct));
  })
);

router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const product = await prisma.product.findUnique({ where: { id: req.params.id } });
    if (!product) return res.status(404).json({ error: '상품을 찾을 수 없습니다.' });
    res.json(serializeProduct(product));
  })
);

router.get(
  '/:id/reviews',
  asyncHandler(async (req, res) => {
    const reviews = await prisma.review.findMany({
      where: { productId: req.params.id },
      orderBy: { createdAt: 'desc' },
    });
    res.json(reviews);
  })
);

const reviewSchema = z.object({
  rating: z.number().int().min(1).max(5),
  comment: z.string().min(1),
  color: z.string().optional(),
});

router.post(
  '/:id/reviews',
  requireAuth,
  asyncHandler(async (req: AuthedRequest, res) => {
    const { rating, comment, color } = reviewSchema.parse(req.body);
    const product = await prisma.product.findUnique({ where: { id: req.params.id } });
    if (!product) return res.status(404).json({ error: '상품을 찾을 수 없습니다.' });
    const user = await prisma.user.findUnique({ where: { id: req.userId } });

    const review = await prisma.review.create({
      data: {
        productId: product.id,
        userId: req.userId,
        authorName: user?.name ?? '익명',
        rating,
        comment,
        color,
      },
    });

    // 상품의 rating/reviewCount 집계 갱신
    const agg = await prisma.review.aggregate({
      where: { productId: product.id },
      _avg: { rating: true },
      _count: true,
    });
    await prisma.product.update({
      where: { id: product.id },
      data: {
        reviewCount: agg._count,
        rating: agg._avg.rating ?? product.rating,
      },
    });

    res.status(201).json(review);
  })
);

export default router;
