import supertest from 'supertest';
import app from '../server'; // We need to export app without starting it directly
import { connectTestDB, clearTestDB, closeTestDB } from './setup';
import User from '../models/User';

const request = supertest(app);

beforeAll(async () => {
  await connectTestDB();
});

afterEach(async () => {
  await clearTestDB();
});

afterAll(async () => {
  await closeTestDB();
});

describe('Authentication API', () => {
  describe('POST /api/auth/register', () => {
    it('should register a new user successfully', async () => {
      const res = await request.post('/api/auth/register').send({
        name: 'Test User',
        phone: '+919999999999',
        password: 'password123',
      });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.token).toBeDefined();
      expect(res.body.refreshToken).toBeDefined();
      expect(res.body.user.name).toBe('Test User');
    });

    it('should fail if phone is invalid', async () => {
      const res = await request.post('/api/auth/register').send({
        name: 'Test User',
        phone: '1234',
        password: 'password123',
      });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.errors).toBeDefined();
    });

    it('should fail if user already exists', async () => {
      await User.create({
        name: 'Existing User',
        phone: '+919999999999',
        passwordHash: 'hashedpassword',
      });

      const res = await request.post('/api/auth/register').send({
        name: 'Test User',
        phone: '+919999999999',
        password: 'password123',
      });

      expect(res.status).toBe(409);
      expect(res.body.success).toBe(false);
    });
  });

  describe('POST /api/auth/login', () => {
    beforeEach(async () => {
      await request.post('/api/auth/register').send({
        name: 'Test Login User',
        phone: '+918888888888',
        password: 'password123',
      });
    });

    it('should login successfully with correct credentials', async () => {
      const res = await request.post('/api/auth/login').send({
        phone: '+918888888888',
        password: 'password123',
      });

      expect(res.status).toBe(200);
      if (res.status !== 200) console.error(res.body);
      expect(res.body.success).toBe(true);
      expect(res.body.token).toBeDefined();
      expect(res.body.refreshToken).toBeDefined();
    });

    it('should fail login with incorrect password', async () => {
      const res = await request.post('/api/auth/login').send({
        phone: '+918888888888',
        password: 'wrongpassword',
      });

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });
  });
});
