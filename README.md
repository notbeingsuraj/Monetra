# Monetra 💳

**A fintech social lending platform for tracking peer-to-peer loans and trust scores.**

Monetra lets users record loans between friends, monitor repayment reliability, and evaluate financial trustworthiness through a calculated trust score. It does **not** transfer money — it records and analyzes lending behavior.

---

## Project Structure

```
Monetra/
├── mobile/         # React Native (Expo) — TypeScript
└── backend/        # Node.js + Express API — TypeScript
```

## Tech Stack

| Layer           | Technology                                |
| --------------- | ----------------------------------------- |
| Mobile          | React Native (Expo), TypeScript           |
| Navigation      | React Navigation v6 (bottom tabs + stack) |
| HTTP Client     | Axios                                     |
| Session Storage | AsyncStorage                              |
| Backend         | Node.js + Express 5                       |
| Database        | MongoDB (Mongoose)                        |
| Auth            | JWT (7-day tokens)                        |
| Scheduling      | node-cron (daily overdue job)             |

---

## Getting Started

### Prerequisites

- Node.js ≥ 18
- MongoDB (local or Atlas)
- Expo CLI (`npm install -g expo-cli`)

### Backend

```bash
cd backend
cp .env .env.local        # update MONGODB_URI and JWT_SECRET
npm install
npm run dev               # starts on http://localhost:5000
```

### Mobile App

```bash
cd mobile
npm install
npx expo start            # scan QR with Expo Go
```

---

## Trust Score Formula

```
Score = 50
      + 5 × loans_repaid
      − 10 × defaults
      − 1 × late_days

Clamped to range: [0, 100]
```

| Range  | Label     |
| ------ | --------- |
| 80–100 | Excellent |
| 65–79  | Good      |
| 50–64  | Fair      |
| 35–49  | Poor      |
| 0–34   | Critical  |

---

## API Reference

### Auth

| Method | Endpoint             | Description       |
| ------ | -------------------- | ----------------- |
| POST   | `/api/auth/register` | Register new user |
| POST   | `/api/auth/login`    | Login             |
| GET    | `/api/auth/me`       | Get current user  |

### Loans

| Method | Endpoint                 | Description                       |
| ------ | ------------------------ | --------------------------------- |
| GET    | `/api/loans`             | List loans (filterable by status) |
| GET    | `/api/loans/summary`     | Dashboard summary                 |
| GET    | `/api/loans/:id`         | Loan detail + repayments          |
| POST   | `/api/loans`             | Create a loan                     |
| PATCH  | `/api/loans/:id/repay`   | Mark as repaid                    |
| PATCH  | `/api/loans/:id/default` | Mark as defaulted                 |
| DELETE | `/api/loans/:id`         | Delete a loan                     |

### Users

| Method | Endpoint                   | Description                 |
| ------ | -------------------------- | --------------------------- |
| GET    | `/api/users/me/score`      | Get trust score breakdown   |
| POST   | `/api/users/me/score/sync` | Recalculate & persist score |
| PATCH  | `/api/users/me`            | Update profile              |

---

## Design System

| Token         | Value     |
| ------------- | --------- |
| Charcoal      | `#1C1C1C` |
| Warm White    | `#F5F5F3` |
| Muted Emerald | `#1F7A63` |
| Neutral Gray  | `#8C8C8C` |

Typography: SF Pro (iOS) / Roboto (Android)  
Spacing: 8px grid system  
Corner radii: 6 / 10 / 16 / 20px

---

## Project Architecture

### Mobile

```
src/
├── components/
│   ├── features/         # LoanCard, TrustScoreBadge
│   └── ui/               # Button
├── contexts/             # AuthContext (global auth state)
├── hooks/                # useLoans
├── navigation/           # AppNavigator (tabs), AuthNavigator (stack)
├── screens/              # 7 screens (Dashboard, Loans, AddLoan, History, Profile, Login, Register)
├── services/             # api.ts, auth.service.ts, loan.service.ts
├── theme/                # colors.ts, typography.ts, spacing.ts
├── types/                # index.ts (all interfaces)
└── utils/                # formatters.ts
```

### Backend

```
src/
├── config/               # db.ts
├── controllers/          # auth, loans, users
├── middleware/           # auth (JWT), error handler
├── models/               # User, Loan, Repayment
├── routes/               # auth, loans, users
├── services/             # trustScore.service, reminder.service
└── server.ts
```

---

## Environment Variables

```bash
# backend/.env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/monetra
JWT_SECRET=your_very_secret_key
JWT_EXPIRES_IN=7d
NODE_ENV=development
```
# Monetra
