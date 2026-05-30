# Architecture — Self-Hosted Data Plane

## Problem

Some teams want Mini Data’s product experience (UI, OAuth, integrations, Contact Engine, etc.) without storing customer data in the operator’s Cloudflare account.

## Solution

Split **control plane** and **data plane**:

| Layer | Where it runs | What it contains |
|-------|---------------|------------------|
| Control plane | `minidata.io` | UI, auth, billing, integrations, AI features, release cadence |
| Data plane | Customer’s Cloudflare account | D1 database, R2 bucket, data worker |

This repository provisions **only the data plane**.

## Provisioning flow

1. Customer runs `npm run provision` in their Cloudflare account.
2. Wrangler creates D1 (+ optional R2), applies schema migrations, and deploys a minimal data worker.
3. Cloudflare assigns a URL such as `https://minidata-self-hosted-data.{subdomain}.workers.dev`.
4. Customer may optionally attach a custom domain (e.g. `data.mojavestud.io`) in Workers → Domains & Routes.
5. Customer pastes that URL in **Settings → Self-Hosted Data** on minidata.io (or runs `npm run register`).
6. minidata.io stores `user_id → data_url` in `self_hosted_bindings` after verifying `GET {data_url}/health`.

## Runtime (platform side)

When a linked user uses minidata.io:

1. User authenticates via Google/GitHub on minidata.io (unchanged).
2. Platform resolves their `self_hosted_bindings.data_url`.
3. API handlers route database operations to the customer’s worker (future phase).
4. UI code path is identical for hosted and self-hosted users.

## Why not ship the full Worker?

Copying `src/index.ts` into customer accounts would:

- Expose proprietary application code
- Fragment release management (every customer on a different version)
- Duplicate OAuth secrets and UI assets per deployment

The provisioning-only model keeps one UI, one auth surface, and isolated data storage.

## Networking options

| URL type | Example | How to get it |
|----------|---------|---------------|
| Cloudflare Workers subdomain | `minidata-data.jess-901.workers.dev` | Automatic after `wrangler deploy` |
| Custom subdomain | `data.mojavestud.io` | Workers → Domains & Routes in Cloudflare dashboard |
| Apex / other domain | `data.example.com` | Same — attach route to your worker |

Only the **origin** (scheme + hostname) is stored on minidata.io — no paths or secrets.

## Related repos

- [Mini-Data](https://github.com/mojavestudio/Mini-Data) — private/platform application (not required for self-hosted data customers)
- **mini-data-self-hosted** (this repo) — public provisioning + schema + data worker stub
