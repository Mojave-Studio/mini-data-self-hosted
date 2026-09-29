<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.png">
    <img src="assets/logo.png" width="300" alt="Mini Data">
  </picture>
</p>

<h1 align="center">Mini Data — Self-Hosted</h1>

<p align="center">
  <em>Your data in your Cloudflare account. Our UI at minidata.io. Nobody's mixed up.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/mojavestudio/mini-data-self-hosted?style=flat-square&color=111111" alt="Stars">
  <img src="https://img.shields.io/badge/license-MIT-111111?style=flat-square" alt="MIT license">
  <img src="https://img.shields.io/badge/runs%20on-Cloudflare%20Workers-111111?style=flat-square" alt="Cloudflare Workers">
  <img src="https://img.shields.io/badge/cost-your%20CF%20plan-111111?style=flat-square" alt="Billed by your account">
</p>

---

One command puts a D1 database, an R2 bucket, and a data worker in **your** Cloudflare account — while the app, auth, and feature updates stay at [minidata.io](https://minidata.io).

```bash
npm run provision
```

That's the whole trick. We never store your records; you never fork our UI.

## What this repo is — and isn't

| In the box | Not in the box |
|------------|----------------|
| D1 + R2 provisioning (`npm run provision`) | Mini Data UI source code |
| Schema migrations — structure only | OAuth config — handled at minidata.io |
| A minimal data worker for your account | Application logic and integrations |

The split keeps every self-hoster on the current UI with zero redeploys, while data-at-rest stays inside your billing and compliance boundary.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  minidata.io (Mini Data platform — UI, auth, integrations) │
└───────────────────────────┬─────────────────────────────────┘
                            │ you link your worker URL in Settings
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Your Cloudflare account                                    │
│  • Worker URL (workers.dev or custom domain)                │
│  • D1 + optional R2  ← this repo provisions + migrates      │
└─────────────────────────────────────────────────────────────┘
```

## Quick start

Prerequisites: [Node.js 18+](https://nodejs.org/), a [Cloudflare account](https://dash.cloudflare.com/), and three minutes.

```bash
git clone https://github.com/mojavestudio/mini-data-self-hosted.git
cd mini-data-self-hosted
npm install
cp .env.example .env
npx wrangler login
npm run provision
```

`provision` creates a D1 database (`mini_data_db`), optionally an R2 bucket, applies every schema migration to **your** D1, deploys the data worker, and prints its URL — e.g. `https://minidata-self-hosted-data.<subdomain>.workers.dev`.

Then link it:

1. Sign in at [minidata.io](https://minidata.io)
2. **Settings → Self-Hosted Data** → paste the worker URL
3. Done. Or `npm run register` with `MINIDATA_SESSION_COOKIE` set if you prefer the CLI.

### Custom domains

Attach a hostname in **Workers → your worker → Settings → Domains & Routes** (e.g. `data.example.com`), then paste that URL in Settings instead. Set `MINIDATA_DATA_URL` in `.env` beforehand if you already know the hostname.

## Commands

| Command | Description |
|---------|-------------|
| `npm run provision` | Create D1/R2, migrate, deploy the worker |
| `npm run provision -- --no-r2` | Skip R2 bucket creation |
| `npm run provision -- --register` | Provision and link in one step |
| `npm run register` | Link an already-deployed worker URL |
| `npm run migrate` | Re-apply migrations after a schema update |
| `npm run deploy` | Redeploy the data worker only |

## Configuration

| Variable | Description |
|----------|-------------|
| `MINIDATA_ORIGIN` | Platform URL (default `https://minidata.io`) |
| `MINIDATA_DATA_URL` | Your worker URL when using a custom domain |
| `MINIDATA_SESSION_COOKIE` | Session cookie for CLI register only |
| `D1_DATABASE_NAME` | D1 database name (default `mini_data_db`) |
| `R2_BUCKET_NAME` | R2 bucket name (auto-generated if unset) |

## Updating

When Mini Data ships new schema migrations:

```bash
git pull
npm run migrate
npm run deploy
```

## Security

- `.env`, `wrangler.toml`, and `.minidata/` are gitignored — **never commit them**
- No secrets live in this repo; the only credential it ever touches is *your* Cloudflare login via `wrangler`
- Data at rest stays in your Cloudflare account under your billing and compliance boundary
- minidata.io verifies the worker at `/health` before linking, and stores only the origin — no paths, no tokens
- `MINIDATA_SESSION_COOKIE` is optional, used once by `register`, and never written to disk by us

## License

MIT — provisioning tooling and schema only. The Mini Data platform itself is proprietary.
