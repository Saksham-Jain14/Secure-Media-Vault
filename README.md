# Secure Media Vault

A private media library with signed uploads, row-scoped access, expiring download links, built with React + TypeScript, GraphQL Yoga, and Supabase.

## Features
- User authentication (Supabase Auth)
- Private file uploads with single-use tickets
- SHA256 verification (Edge Function)
- Row-level security enforced
- Short-lived signed download links (≈90s)
- Gallery UI with upload state machine, cancel/retry
- Global toast notifications

## Stack
- Frontend: React + Vite + TypeScript
- Backend: GraphQL Yoga + TypeScript
- Database & Storage: Supabase (Postgres + Storage)
- Optional: Redis for queue/retry

## Setup

```bash
pnpm install
pnpm db:reset && pnpm db:migrate && pnpm db:seed
pnpm dev
