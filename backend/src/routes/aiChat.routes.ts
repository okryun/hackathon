import { Router } from 'express';
import { z } from 'zod';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../middleware/errorHandler';
import { optionalAuth, AuthedRequest } from '../middleware/requireAuth';

const router = Router();
router.use(optionalAuth);

const chatSchema = z.object({
  productId: z.string().optional(),
  message: z.string().min(1),
});

async function generateReply(message: string, productName: string | null): Promise<string> {
  const apiKey = process.env.ANTHROPIC_API_KEY;

  if (!apiKey) {
    // 키가 없으면 프론트엔드에 있던 기존 Mock 응답과 동일한 형태로 대체.
    const name = productName ?? '이 상품';
    return `"${name}" 관련 답변입니다 (Mock 응답).\n실제 서비스에서는 AI가 상품 정보를 바탕으로 상세히 답변드립니다.`;
  }

  const { default: Anthropic } = await import('@anthropic-ai/sdk');
  const client = new Anthropic({ apiKey });

  const systemPrompt = productName
    ? `당신은 오프라인 패션 매장의 AI 쇼핑 컨시어지입니다. 고객이 "${productName}" 상품에 대해 질문합니다. 사이즈, 소재, 관리 방법, 색상 조합, 코디 추천 등 상품 관련 문의에 친절하고 간결하게 한국어로 답변하세요.`
    : `당신은 오프라인 패션 매장의 AI 쇼핑 컨시어지입니다. 친절하고 간결하게 한국어로 답변하세요.`;

  const response = await client.messages.create({
    model: 'claude-sonnet-4-5',
    max_tokens: 400,
    system: systemPrompt,
    messages: [{ role: 'user', content: message }],
  });

  const textBlock = response.content.find((b: any) => b.type === 'text') as any;
  return textBlock?.text ?? '죄송해요, 답변을 생성하지 못했어요.';
}

router.post(
  '/',
  asyncHandler(async (req: AuthedRequest, res) => {
    const { productId, message } = chatSchema.parse(req.body);

    let productName: string | null = null;
    if (productId) {
      const product = await prisma.product.findUnique({ where: { id: productId } });
      productName = product?.name ?? null;
    }

    await prisma.chatMessage.create({
      data: { userId: req.userId, productId, role: 'user', content: message },
    });

    const reply = await generateReply(message, productName);

    await prisma.chatMessage.create({
      data: { userId: req.userId, productId, role: 'assistant', content: reply },
    });

    res.json({ reply });
  })
);

export default router;
