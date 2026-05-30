# Mini Data — Self-Hosted Data Plane

Provision **your own** Cloudflare D1, R2, and data worker while using the Mini Data UI at **[minidata.io](https://minidata.io)**.

This repository is **not** a copy of the Mini Data application. It contains:

- Provisioning scripts (`npm run provision`)
- Database schema migrations (structure only)
- A minimal data worker deployed to **your** Cloudflare account

Your UI, auth, and feature updates stay on minidata.io. Your **data never lives in our Cloudflare account**.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  minidata.io (Mini Data platform — UI, auth, integrations) │
└───────────────────────────┬─────────────────────────────────┘
                            │ you link your worker URL in Settings
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Your Cloudflare account                                    │
│  • Worker URL (workers.dev or custom domain)                  │
│  • D1 + optional R2  ← this repo provisions + migrates      │
└─────────────────────────────────────────────────────────────┘
```

## Quick start

### 1. Prerequisites

- [Node.js 18+](https://nodejs.org/)
- A [Cloudflare account](https://dash.cloudflare.com/)
- Wrangler CLI: `npm install` (included as devDependency)

### 2. Install

```bash
git clone https://github.com/mojavestudio/mini-data-self-hosted.git
cd mini-data-self-hosted
npm install
cp .env.example .env
npx wrangler login
```

### 3. Provision in **your** account

```bash
npm run provision
```

This will:

1. Create a D1 database (`mini_data_db` by default)
2. Optionally create an R2 bucket for file storage
3. Apply schema migrations to **your** D1
4. Deploy the data worker and print its URL (e.g. `https://minidata-self-hosted-data.your-subdomain.workers.dev`)

### 4. Link to your Mini Data login

Copy the worker URL from the provision output (or `.minidata/data-url.txt`).

**Option A — UI (recommended)**

1. Sign in at [minidata.io](https://minidata.io)
2. Go to **Settings → Self-Hosted Data**
3. Paste your worker URL — either the Cloudflare `*.workers.dev` address or a custom domain

**Option B — CLI**

```bash
# After signing in at minidata.io, copy your `session` cookie into .env
npm run register
```

Or provision and register in one step:

```bash
npm run provision -- --register
```

### Custom domains

After deploy, you can attach your own hostname in the Cloudflare dashboard:

**Workers → your worker → Settings → Domains & Routes**

Examples:

- `https://minidata-data.jess-901.workers.dev` (Cloudflare-assigned)
- `https://data.mojavestud.io` (your subdomain or apex domain)

Then paste that URL in Mini Data Settings instead of the default `workers.dev` URL.

Set `MINIDATA_DATA_URL=https://data.mojavestud.io` in `.env` before `npm run provision` if you already know the hostname you will use.

## What this repo does **not** include

- Mini Data UI source code
- OAuth configuration (handled by minidata.io)
- Application business logic or integrations

Those remain on the hosted platform so you always get the latest features without redeploying an app fork.

## Configuration

| Variable | Description |
|----------|-------------|
| `MINIDATA_ORIGIN` | Platform URL (default `https://minidata.io`) |
| `MINIDATA_DATA_URL` | Your worker URL if using a custom domain (optional) |
| `D1_DATABASE_NAME` | D1 database name (default `mini_data_db`) |
| `R2_BUCKET_NAME` | R2 bucket name (auto-generated if unset) |
| `MINIDATA_SESSION_COOKIE` | For CLI register only |

## Commands

| Command | Description |
|---------|-------------|
| `npm run provision` | Create D1/R2, migrate, deploy worker |
| `npm run provision -- --no-r2` | Skip R2 bucket creation |
| `npm run register` | Link worker URL to minidata.io account |
| `npm run migrate` | Re-apply migrations after platform schema updates |
| `npm run deploy` | Redeploy the data worker only |

## Updating schema

When Mini Data releases new migrations, pull this repo and run:

```bash
git pull
npm run migrate
npm run deploy
```

## Security

- **Never commit** `.minidata/` or `.env`.
- Data at rest stays in **your** Cloudflare account under your billing and compliance boundary.
- minidata.io verifies your worker responds at `/health` before linking.

## License

MIT — provisioning tooling and schema migrations only.
