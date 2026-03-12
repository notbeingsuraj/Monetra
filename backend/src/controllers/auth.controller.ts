import { Request, Response, NextFunction } from 'express';
import { AuthService } from '../services/auth.service';
import User from '../models/User';

export const register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { name, email, phone, password } = req.body;
    if (!name || !password) {
      res.status(400).json({ success: false, message: 'Name and password are required' });
      return;
    }
    if (!email && !phone) {
      res.status(400).json({ success: false, message: 'Email or phone is required' });
      return;
    }

    const { user, token, refreshToken } = await AuthService.registerUser({ name, email, phone, password });

    res.status(201).json({
      success: true,
      token,
      refreshToken,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        trustScore: user.trustScore,
      },
    });
  } catch (err: any) {
    if (err.message.includes('User already exists')) {
      res.status(409).json({ success: false, message: err.message });
      return;
    }
    next(err);
  }
};

export const login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, phone, password } = req.body;
    if (!password || (!email && !phone)) {
      res.status(400).json({ success: false, message: 'Credentials are required' });
      return;
    }

    const { user, token, refreshToken } = await AuthService.loginUser({ email, phone, password });

    res.status(200).json({
      success: true,
      token,
      refreshToken,
      user: {
        _id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        trustScore: user.trustScore,
      },
    });
  } catch (err: any) {
    if (err.message === 'Invalid credentials') {
      res.status(401).json({ success: false, message: err.message });
      return;
    }
    next(err);
  }
};

export const getMe = async (req: Request & { user?: InstanceType<typeof User> }, res: Response, next: NextFunction): Promise<void> => {
  try {
    res.status(200).json({ success: true, user: req.user });
  } catch (err) {
    next(err);
  }
};

export const refreshAuth = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      res.status(400).json({ success: false, message: 'Refresh token is required' });
      return;
    }

    const tokens = await AuthService.refreshAuth(refreshToken);
    res.status(200).json({ success: true, ...tokens });
  } catch (err: any) {
    res.status(401).json({ success: false, message: err.message });
  }
};

export const logout = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await AuthService.logoutUser(req.body.refreshToken);
    res.status(200).json({ success: true, message: 'Logged out successfully' });
  } catch (err) {
    next(err);
  }
};

export const sendOtp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userReq = req as any;
    const userId = userReq.user?.id;
    if (!userId) {
      res.status(401).json({ success: false, message: 'Not authorized' });
      return;
    }
    
    await AuthService.sendOtp(userId);
    res.status(200).json({ success: true, message: 'OTP sent successfully' });
  } catch (error: any) {
    if (error.message === 'User or phone number not found') {
      res.status(400).json({ success: false, message: error.message });
    } else {
      next(error);
    }
  }
};

export const verifyOtp = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userReq = req as any;
    const userId = userReq.user?.id;
    if (!userId) {
      res.status(401).json({ success: false, message: 'Not authorized' });
      return;
    }

    const { otp } = req.body;
    await AuthService.verifyOtp(userId, otp);
    res.status(200).json({ success: true, message: 'Phone verified successfully' });
  } catch (error: any) {
    res.status(400).json({ success: false, message: error.message });
  }
};
