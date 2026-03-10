# Monetra – AI Development Prompt

## Project Name

Monetra

## Project Type

Mobile Application (Fintech / Social Lending)

## Objective

Build a clean, modern mobile application called **Monetra** that helps users track loans between friends and evaluate financial trustworthiness using a trust score system.

The application should feel like a **professional fintech product**, not a generic AI-generated UI.

The goal is to deliver a **production-quality MVP** with strong UX, clear architecture, and maintainable code.

---

# Core Product Concept

Monetra allows users to:

• record money lent to friends
• track repayments
• monitor loan history
• calculate a trust score based on repayment behavior

Monetra does **not function as a lending platform** and does not handle money transfers.

It simply records and analyzes peer-to-peer lending behavior.

---

# Technology Stack

Mobile Application
React Native (Expo)

Language
TypeScript

Backend
Node.js + Express

Database
MongoDB

Authentication
JWT with phone/email login

Notifications
Push notifications for loan reminders

---

# Core Features

## 1. Authentication

Users should be able to create accounts using:

• phone number with OTP
• email login

User profiles should include:

• name
• phone/email
• trust score
• loan history

---

## 2. Dashboard

The dashboard should display a financial overview.

Elements:

Trust Score Card
Money Lent Summary
Money Borrowed Summary
Active Loans

The dashboard should act as the **central overview of financial relationships**.

---

## 3. Add Loan

Users can record a new loan.

Fields:

Borrower name
Loan amount
Due date
Optional note

After creation, the loan should appear in the user's active loans list.

---

## 4. Loan Tracking

Loans should have three states:

Pending
Repaid
Overdue

Users can mark a loan as repaid manually.

---

## 5. Trust Score System

The app calculates a trust score based on repayment behavior.

Initial formula:

Score = 50

- 5 × loans repaid
  − 10 × defaults
  − 1 × late days

Score range:

0–100

---

## 6. Notifications

The system should notify users for:

• upcoming repayment deadlines
• overdue loans

Notifications should be subtle and helpful.

---

# UX / UI Guidelines

The interface must NOT look like a typical AI-generated application.

Avoid:

• overly bright gradients
• neon color schemes
• forced blue/pink palettes
• heavy glassmorphism

Design should feel like a **premium fintech product**.

---

# Design Language

Style:

Minimal
Clean
Professional
Data-focused

Spacing:

Use a consistent **8px grid system**.

Typography:

Use modern fonts such as:

Inter
SF Pro
Roboto

---

# Color Palette

Primary

Charcoal
#1C1C1C

Background

Warm neutral
#F5F5F3

Accent

Muted emerald
#1F7A63

Secondary

Neutral gray
#8C8C8C

These colors should communicate **trust and stability**.

---

# Navigation Structure

Use bottom tab navigation with the following sections:

Dashboard
Loans
Add Loan
History
Profile

---

# Folder Structure

Mobile App

/components
/screens
/navigation
/hooks
/services
/utils
/styles

Backend

/routes
/controllers
/models
/middleware
/services

---

# Code Quality Requirements

The generated code must follow:

• modular architecture
• reusable components
• strong typing using TypeScript
• clear separation of concerns
• maintainable folder structure

Avoid monolithic files.

---

# Performance Requirements

• fast screen rendering
• minimal unnecessary re-renders
• optimized API calls

---

# Deliverables

The AI should generate:

1. Mobile app structure
2. Backend API structure
3. Database models
4. Key UI screens
5. Core business logic

The result should be a **clean, scalable MVP foundation** suitable for further development.

---

# Development Goal

Create a **high-quality fintech MVP** that could realistically be used as the foundation for a startup product.
