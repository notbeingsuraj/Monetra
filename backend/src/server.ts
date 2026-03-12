import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { connectDB } from './config/db';
import { errorHandler, notFound } from './middleware/error.middleware';
import { startReminderService } from './services/reminder.service';
import helmet from 'helmet';
import { globalLimiter, authLimiter } from './middleware/rateLimit.middleware';
import authRoutes from './routes/auth.routes';
import loanRoutes from './routes/loan.routes';
import userRoutes from './routes/user.routes';
import * as Sentry from '@sentry/node';
import { nodeProfilingIntegration } from '@sentry/profiling-node';

dotenv.config();

Sentry.init({
  dsn: process.env.SENTRY_DSN || '',
  integrations: [
    nodeProfilingIntegration(),
  ],
  // Performance Monitoring
  tracesSampleRate: 1.0, 
  // Set sampling rate for profiling - this is relative to tracesSampleRate
  profilesSampleRate: 1.0,
});

const app = express();
const PORT = parseInt(process.env.PORT || '5000', 10);

// ─────── Sentry Request Handler ───────
// The request handler must be the first middleware on the app
Sentry.setupExpressErrorHandler(app);

// ─────── Security Middleware ───────
app.use(helmet());
app.use('/api', globalLimiter);
app.use('/api/auth', authLimiter);

// ─────── Standard Middleware ───────
app.use(cors({
  origin: process.env.NODE_ENV === 'production' ? process.env.ALLOWED_ORIGIN || '*' : '*',
  methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS', 'PUT'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Idempotency-Key'],
}));
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));

// ─────── Health check ───────
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok', service: 'Monetra API', version: '1.0.0' });
});

// ─────── Routes ───────
app.use('/api/auth', authRoutes);
app.use('/api/loans', loanRoutes);
app.use('/api/users', userRoutes);

// ─────── Error handling ───────
// Sentry error handler must be before any other error middleware and after all controllers
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

if (process.env.NODE_ENV !== 'test') {
  start();
}

export default app;
