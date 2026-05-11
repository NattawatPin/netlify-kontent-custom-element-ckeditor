# BH Digital Commerce — AI Coding Instructions

## 🏗️ Architecture Overview

This project consists of multiple layers:
- **Web (New)**: Next.js 14+ with App Router
- **Web (Legacy)**: ASP.NET C# with React JS plugins
- **Mobile (New)**: Flutter
- **Mobile (Legacy)**: Swift (iOS), Kotlin (Android)
- **Backend (New)**: NestJS (Node.js)
- **Backend (Legacy)**: C# — do NOT refactor unless explicitly asked

---

## 📐 Pattern & Architecture Rules

### Next.js (New Web)
- Use App Router only — no Pages Router
- Follow Atomic Design: atoms → molecules → organisms → templates → pages
- Server Components by default — use Client Components only when needed
- Data fetching in Server Components, never in Client Components directly

### NestJS (New Backend)
- Follow Clean Architecture strictly:
  - Controller → Use Case → Repository → Entity
- Never put business logic in Controllers
- Always use Repository Pattern for data access
- Dependency Injection for all services
- DTO validation with class-validator on every endpoint

### Flutter (New Mobile)
- Use BLoC Pattern for state management
- Never put business logic in Widgets
- Separate: UI Layer / BLoC Layer / Repository Layer / Data Layer

### Legacy Code (ASP.NET / Swift / Kotlin)
- Do NOT refactor existing patterns
- When adding new features: create new files following new patterns
- Wrap legacy functionality with adapter classes if needed

---

## 📁 Folder Structure

### Next.js
```
src/
  ├── app/                 ← App Router pages
  ├── components/
  │   ├── atoms/
  │   ├── molecules/
  │   ├── organisms/
  │   └── templates/
  ├── hooks/               ← Custom hooks only
  ├── lib/                 ← Utilities, helpers
  ├── services/            ← API calls
  └── types/               ← TypeScript types/interfaces
```

### NestJS
```
src/
  ├── modules/
  │   └── [feature]/
  │       ├── controllers/
  │       ├── use-cases/
  │       ├── repositories/
  │       ├── entities/
  │       └── dto/
  ├── common/              ← Shared utilities
  └── config/              ← Configuration
```

---

## ✅ Code Standards

### TypeScript (Next.js + NestJS)
- Strict mode always ON
- No `any` type — use `unknown` if truly unknown
- Every function must have explicit return type
- Interface over Type for object shapes
- Enum for constants with multiple values

### Naming Conventions
- Component/Class: `PascalCase`
- Function/Variable: `camelCase`
- Constant: `UPPER_SNAKE_CASE`
- File: `kebab-case.ts`
- Interface: prefix with `I` → `IUserRepository`
- DTO: suffix with `Dto` → `CreateOrderDto`

### Comments & Documentation
- JSDoc for all public functions
- Inline comments for complex business logic only
- No commented-out code — use git instead

---

## 🔒 Security Rules
- Never hardcode secrets, API keys, or credentials
- Always use environment variables via `.env`
- Validate all inputs at API boundary (DTO level)
- Never expose internal error details to client
- Patient data must never be logged

---

## 🏥 Healthcare & E-Commerce Specific
- Patient data (PII/PHI): never log, never expose in URLs
- Payment data: never store raw card data — tokenize only
- All monetary values: use integer (satang/cents) never float
- Voucher/Gift Card operations: must be idempotent
- Order status changes: must be logged with timestamp + actor

---

## ❌ Anti-patterns — Never Do These
- No business logic in UI components
- No direct database calls from Controllers
- No `console.log` in production code — use logger service
- No synchronous file operations
- No `// TODO` without ticket number reference
- No magic numbers — use named constants

---

## 🧪 Testing Requirements
- Unit test for all Use Cases
- Integration test for all API endpoints
- Component test for complex UI components
- Minimum coverage: 70%

---

## 📦 Dependencies
- Before adding any new package: check if existing library can solve it
- Prefer well-maintained packages (>1M weekly downloads)
- No packages with known security vulnerabilities
- Document why each major dependency was chosen
```

---