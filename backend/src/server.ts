import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { connectDB } from './config/db';
import { errorHandler, notFound } from './middleware/error.middleware';
import { startReminderService } from './services/reminder.service';
import authRoutes from './routes/auth.routes';
import loanRoutes from './routes/loan.routes';
import userRoutes from './routes/user.routes';

dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '5000', 10);

// ─────── Middleware ───────
app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? process.env.ALLOWED_ORIGIN : '*',
  methods: ['GET', 'POST', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true }));

// ─────── Health check ───────
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok', service: 'Monetra API', version: '1.0.0' });
});

// ─────── Routes ───────
app.use('/api/auth', authRoutes);
app.use('/api/loans', loanRoutes);
app.use('/api/users', userRoutes);

// ─────── Error handling ───────
app.use(notFound);
app.use(errorHandler);

// ─────── Boot ───────
const start = async () => {
  await connectDB();
  startReminderService();
  app.listen(PORT, () => {
    console.log(`🚀 Monetra API running on http://localhost:${PORT}`);
  });
};

start();

export default app;
