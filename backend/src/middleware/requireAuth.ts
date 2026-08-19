import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../lib/auth';

export interface AuthedRequest extends Request {
  userId?: string;
}

/** 로그인이 반드시 필요한 라우트에 사용 (Authorization: Bearer <token>) */
export function requireAuth(req: AuthedRequest, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ error: '인증이 필요합니다.' });
  }
  const token = header.slice(7);
  try {
    const payload = verifyToken(token);
    req.userId = payload.userId;
    next();
  } catch {
    return res.status(401).json({ error: '유효하지 않은 토큰입니다.' });
  }
}

/** 로그인 여부와 무관하게 동작하되, 토큰이 있으면 userId를 채워주는 라우트에 사용 */
export function optionalAuth(req: AuthedRequest, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (header?.startsWith('Bearer ')) {
    try {
      req.userId = verifyToken(header.slice(7)).userId;
    } catch {
      // 잘못된 토큰이면 그냥 비로그인 상태로 진행
    }
  }
  next();
}
