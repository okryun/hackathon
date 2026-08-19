import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../middleware/errorHandler';
import { optionalAuth, AuthedRequest } from '../middleware/requireAuth';

const router = Router();
router.use(optionalAuth); // 비로그인 상태에서도 AR 체험 자체는 가능

const startSchema = z.object({ productId: z.string() });

router.post(
  '/start',
  asyncHandler(async (req: AuthedRequest, res) => {
    const { productId } = startSchema.parse(req.body);
    const product = await prisma.product.findUnique({ where: { id: productId } });
    if (!product) return res.status(404).json({ error: '상품을 찾을 수 없습니다.' });

    // 진행 중인 세션이 있으면 먼저 종료 처리 (Flutter ArSessionProvider.start와 동일한 규칙)
    if (req.userId) {
      const active = await prisma.arSession.findFirst({ where: { userId: req.userId, endTime: null } });
      if (active) {
        await prisma.arSession.update({ where: { id: active.id }, data: { endTime: new Date() } });
      }
    }

    const session = await prisma.arSession.create({ data: { userId: req.userId, productId } });
    res.status(201).json(session);
  })
);

router.post(
  '/:sessionId/end',
  asyncHandler(async (req, res) => {
    const session = await prisma.arSession.findUnique({ where: { id: req.params.sessionId } });
    if (!session) return res.status(404).json({ error: '세션을 찾을 수 없습니다.' });
    const updated = await prisma.arSession.update({
      where: { id: session.id },
      data: { endTime: session.endTime ?? new Date() },
    });
    res.json(updated);
  })
);

router.get(
  '/history',
  asyncHandler(async (req: AuthedRequest, res) => {
    if (!req.userId) return res.json([]);
    const sessions = await prisma.arSession.findMany({
      where: { userId: req.userId },
      orderBy: { startTime: 'desc' },
    });
    res.json(sessions);
  })
);

// 상품별 AR 사용 횟수 / 누적 체험 시간 (매장 운영 분석용)
router.get(
  '/stats/:productId',
  asyncHandler(async (req, res) => {
    const sessions = await prisma.arSession.findMany({ where: { productId: req.params.productId } });
    const usageCount = sessions.length;
    const totalDurationSeconds = sessions.reduce((sum, s) => {
      const end = s.endTime ?? new Date();
      return sum + Math.floor((end.getTime() - s.startTime.getTime()) / 1000);
    }, 0);
    res.json({ productId: req.params.productId, usageCount, totalDurationSeconds });
  })
);

export default router;
