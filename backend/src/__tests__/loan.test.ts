import supertest from 'supertest';
import app from '../server';
import { connectTestDB, clearTestDB, closeTestDB } from './setup';
import User from '../models/User';

const request = supertest(app);

let token: string;
let userId: string;

beforeAll(async () => {
  await connectTestDB();
});

beforeEach(async () => {
  // Create user and login
  const res = await request.post('/api/auth/register').send({
    name: 'Loan Tester',
    phone: '+919999000011',
    password: 'password123',
  });
  token = res.body.token;
  userId = res.body.user._id;
});

afterEach(async () => {
  await clearTestDB();
});

afterAll(async () => {
  await closeTestDB();
});

describe('Loan API', () => {
  describe('POST /api/loans', () => {
    it('should create a loan successfully', async () => {
      const res = await request
        .post('/api/loans')
        .set('Authorization', `Bearer ${token}`)
        .set('Idempotency-Key', 'unique-key-1')
        .send({
          borrowerName: 'Test Borrower',
          borrowerContact: '+918888000022',
          amount: 5000,
          dueDate: new Date(Date.now() + 86400000 * 30).toISOString(), // 30 days future
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.amount).toBe(5000);
      expect(res.body.data.lenderId).toBe(userId);
    });

    it('should require authentication', async () => {
      const res = await request.post('/api/loans').set('Idempotency-Key', 'unique-key-2').send({
        borrowerName: 'Test Borrower',
        amount: 5000,
        dueDate: new Date(Date.now() + 86400000 * 30).toISOString(),
      });

      expect(res.status).toBe(401);
    });

    it('should fail with invalid amount', async () => {
      const res = await request
        .post('/api/loans')
        .set('Authorization', `Bearer ${token}`)
        .set('Idempotency-Key', 'unique-key-3')
        .send({
          borrowerName: 'Test Borrower',
          borrowerContact: '+918888000022',
          amount: -5000, // Invalid
          dueDate: new Date(Date.now() + 86400000 * 30).toISOString(),
        });

      expect(res.status).toBe(400);
      expect(res.body.errors).toBeDefined();
    });
  });

  describe('Idempotency logic via POST /api/loans', () => {
    it('should return same response for repeated idempotent requests', async () => {
      const idempotencyKey = 'some-unique-req-id-123';
      
      const payload = {
        borrowerName: 'Idempotent Borrower',
        borrowerContact: '+918888000022',
        amount: 2000,
        dueDate: new Date(Date.now() + 86400000 * 30).toISOString(),
      };

      // First Request
      const res1 = await request
        .post('/api/loans')
        .set('Authorization', `Bearer ${token}`)
        .set('Idempotency-Key', idempotencyKey)
        .send(payload);

      expect(res1.status).toBe(201);

      // Second Request with SAME key
      const res2 = await request
        .post('/api/loans')
        .set('Authorization', `Bearer ${token}`)
        .set('Idempotency-Key', idempotencyKey)
        .send(payload);

      expect(res2.status).toBe(201);
      // It should literally be the same database ID returned 
      expect(res2.body.data._id).toBe(res1.body.data._id);

      // Verify DB only has ONE loan
      const getRes = await request
        .get('/api/loans')
        .set('Authorization', `Bearer ${token}`);
      
      expect(getRes.body.data.length).toBe(1);
    });

    it('should reject if Idempotency-Key is missing on financial POST', async () => {
      const res = await request
        .post('/api/loans')
        .set('Authorization', `Bearer ${token}`)
        .send({
          borrowerName: 'Test Borrower',
          borrowerContact: '+918888000022',
          amount: 5000,
          dueDate: new Date(Date.now() + 86400000 * 30).toISOString(),
        });
      
      // We made it required in the middleware handling, but didn't strictly enforce across all
      // The idempotency middleware currently checks if(!idempotencyKey) { res.status(400) }
      expect(res.status).toBe(400);
      expect(res.body.message).toMatch(/Idempotency-Key header is required/);
    });
  });
});
