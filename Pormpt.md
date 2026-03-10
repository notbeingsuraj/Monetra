# Monetra – Mobile App Prompt

## Project Overview

Build a production-quality mobile application called **Monetra**.

Monetra is a **social lending trust platform** that helps people track money lent between friends and evaluate repayment reliability.

The app allows users to:

• record loans between people
• track repayments
• calculate a trust score
• receive repayment reminders

The goal is to create a **clean, modern fintech product** — not a typical AI generated UI.

---

## Tech Stack

Mobile:
React Native (Expo)

Backend:
Node.js + Express

Database:
MongoDB

Authentication:
JWT + phone/email login

---

## Core Product Concept

Monetra measures **financial trust**.

Instead of credit score from banks, users have a **Trust Score** based on:

• loans repaid
• repayment delays
• defaults

---

## Core Features

### 1. Authentication

Phone or email login

### 2. Dashboard

Displays:
• Trust score
• Active loans
• Money lent
• Money borrowed

### 3. Add Loan

User can create a new loan record:

Fields:
• borrower
• amount
• due date
• optional note

### 4. Loan Tracking

Loan states:

pending
repaid
overdue

### 5. Trust Score

Calculated using repayment behavior.

### 6. Notifications

Repayment reminders before due date.

---

## UI/UX Design Principles

The UI must **not look like a generic AI generated app**.

Design guidelines:

• minimal
• fintech grade
• strong typography
• generous spacing
• neutral colors

Avoid:
• neon gradients
• excessive blue/pink
• glassmorphism spam

Preferred palette:

Primary:
Deep charcoal (#1C1C1C)

Accent:
Muted emerald (#1F7A63)

Background:
Warm neutral (#F5F5F3)

Secondary:
Soft gray (#8C8C8C)

---

## Navigation Structure

Bottom tab navigation:

Dashboard
Loans
Add Loan
History
Profile

---

## Code Quality Requirements

Use:

• modular architecture
• reusable components
• clean folder structure
• TypeScript

---

## Folder Structure

mobile/

components
screens
navigation
hooks
services
utils
styles

backend/

routes
controllers
models
middleware
services

---

## Goal

Produce a **real startup-quality MVP** that feels like a professional fintech product.
