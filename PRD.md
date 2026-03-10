# Monetra – Product Requirements Document (PRD)

## 1. Product Overview

Monetra is a mobile application that enables users to track loans between friends, family, and peers while generating a trust score based on repayment behavior.

The product aims to introduce transparency and accountability in informal peer-to-peer lending.

Monetra does not act as a lender or financial institution. Instead, it provides a trust infrastructure that records transactions and analyzes repayment patterns.

---

## 2. Problem Statement

Informal lending between friends and acquaintances often leads to conflicts due to:

• Lack of documentation
• Forgotten repayment timelines
• No way to measure trustworthiness
• Difficulty asking for repayment

Traditional credit scoring systems do not include informal lending activities.

---

## 3. Product Vision

To create a **social financial trust layer** that helps people make smarter lending decisions within their personal networks.

---

## 4. Target Users

Primary Users

• College students
• Young professionals
• Flatmates and roommates
• Friend groups
• Small peer communities

Secondary Users

• Freelancers
• Small business owners
• Community lending groups

---

## 5. Core Value Proposition

Monetra allows users to:

• record loans easily
• track repayments transparently
• calculate trust scores
• reduce disputes over money

---

## 6. Key Features

### 6.1 User Authentication

Users can sign up using phone number or email.

Features:
• OTP verification
• secure login
• profile creation

---

### 6.2 Dashboard

Displays financial overview including:

• Trust Score
• Money Lent
• Money Borrowed
• Active Loans

---

### 6.3 Add Loan

Users can record loans with the following fields:

• borrower name
• loan amount
• due date
• optional note

---

### 6.4 Loan Tracking

Loan states:

Pending
Repaid
Overdue

Users can update repayment status.

---

### 6.5 Trust Score System

A trust score is calculated based on repayment behavior.

Initial formula:

Score = 50

- 5 × loans repaid
  − 10 × defaults
  − 1 × late days

Score range: 0–100

---

### 6.6 Notifications

The app will notify users for:

• repayment reminders
• overdue loans

---

## 7. User Journey

Step 1
User installs Monetra and signs up.

Step 2
User adds a loan record.

Step 3
Loan appears in dashboard.

Step 4
Borrower repays loan.

Step 5
Trust score updates.

---

## 8. Success Metrics

Key metrics to track:

• number of loans recorded
• repayment rate
• daily active users
• average trust score accuracy

---

## 9. MVP Scope

The MVP will include:

• authentication
• dashboard
• loan recording
• loan tracking
• trust score calculation
• notifications

Excluded from MVP:

• payment integrations
• AI risk analysis
• lending marketplace

---

## 10. Future Roadmap

Phase 2

• predictive risk analysis
• payment integrations
• social lending network

Phase 3

• financial reputation profiles
• lending marketplace
