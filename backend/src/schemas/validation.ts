import { z } from 'zod';

// Reusable phone number format regex (E.164-ish for India + others)
const phoneRegex = /^\+?[1-9]\d{6,14}$/;

export const registerSchema = z.object({
  body: z.object({
    name: z.string().min(2, 'Name must be at least 2 characters').max(50),
    phone: z.string().regex(phoneRegex, 'Invalid phone number format. Must include country code (e.g. +91)'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    phone: z.string().regex(phoneRegex, 'Invalid phone number format'),
    password: z.string().min(1, 'Password is required'),
  }),
});

export const refreshSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token is required'),
  }),
});

export const verifyOtpSchema = z.object({
  body: z.object({
    otp: z.string().length(6, 'OTP must be exactly 6 digits'),
  }),
});

export const createLoanSchema = z.object({
  body: z.object({
    borrowerName: z.string().min(2).max(100).optional(),
    borrowerContact: z.string().regex(phoneRegex, 'Invalid phone number format'),
    amount: z.number().positive('Amount must be positive'),
    interest: z.number().min(0).max(100).optional().default(0),
    currency: z.string().length(3).optional().default('INR'),
    dueDate: z.string().refine(val => !isNaN(Date.parse(val)) && new Date(val).getTime() > Date.now(), {
      message: 'Due date must be a valid future date',
    }),
    note: z.string().max(500).optional(),
  }),
});

export const repayLoanSchema = z.object({
  body: z.object({
    note: z.string().max(500).optional(),
  }),
});
