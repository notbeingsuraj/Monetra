import { Request, Response, NextFunction } from 'express';
import { ZodObject, ZodTypeAny, ZodError } from 'zod';

export const validate = (schema: ZodObject<any, any> | ZodTypeAny) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (error: any) {
      if (error instanceof ZodError) {
        const zError = error as ZodError;
        const errors = zError.issues.map((err: any) => ({
          field: err.path.join('.'),
          message: err.message,
        }));
        res.status(400).json({ success: false, errors });
        return;
      }
      next(error);
    }
  };
};
