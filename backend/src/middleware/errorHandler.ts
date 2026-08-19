import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';

export function errorHandler(err: any, _req: Request, res: Response, _next: NextFunction) {
  if (err instanceof ZodError) {
    return res.status(400).json({
      error: '요청 값이 올바르지 않습니다.',
      details: err.issues.map((i) => ({ path: i.path.join('.'), message: i.message })),
    });
  }

  console.error(err);
  const status = err.status || 500;
  res.status(status).json({ error: err.message || '서버 오류가 발생했습니다.' });
}

export function asyncHandler(fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
