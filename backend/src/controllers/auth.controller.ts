import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import User from '../models/User';

const generateToken = (id: string): string => {
  const secret = process.env.JWT_SECRET!;
  const expiresIn = (process.env.JWT_EXPIRES_IN || '7d') as `${number}${'s' | 'm' | 'h' | 'd' | 'w' | 'y'}` | string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return jwt.sign({ id }, secret, { expiresIn: expiresIn as any });
};

// POST /api/auth/register
export const register = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { name, email, phone, password } = req.body as {
      name: string;
      email?: string;
      phone?: string;
      password: string;
    };

    if (!name || !password) {
      res.status(400).json({ success: false, message: 'Name and password are required' });
      return;
    }

    if (!email && !phone) {
      res.status(400).json({ success: false, message: 'Email or phone is required' });
      return;
    }

    const existing = await User.findOne({
      $or: [email ? { email } : {}, phone ? { phone } : {}].filter(
        (q) => Object.keys(q).length > 0
      ),
    });

    if (existing) {
      res.status(409).json({ success: false, message: 'User already exists with this email or phone' });
      return;
    }

    const user = await User.create({
      name,
      email,
      phone,
      passwordHash: password,
    });

    const token = generateToken(user._id.toString());

    res.status(201).json({
      success: true,
      token,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        trustScore: user.trustScore,
      },
    });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/login
export const login = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, phone, password } = req.body as {
      email?: string;
      phone?: string;
      password: string;
    };

    if (!password || (!email && !phone)) {
      res.status(400).json({ success: false, message: 'Credentials are required' });
      return;
    }

    const query = email ? { email } : { phone };
    const user = await User.findOne(query).select('+passwordHash');

    if (!user) {
      res.status(401).json({ success: false, message: 'Invalid credentials' });
      return;
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      res.status(401).json({ success: false, message: 'Invalid credentials' });
      return;
    }

    const token = generateToken(user._id.toString());

    res.status(200).json({
      success: true,
      token,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        trustScore: user.trustScore,
      },
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/auth/me
export const getMe = async (
  req: Request & { user?: InstanceType<typeof User> },
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // req.user is set by protect middleware
    const user = (req as any).user;
    res.status(200).json({ success: true, user });
  } catch (err) {
    next(err);
  }
};
