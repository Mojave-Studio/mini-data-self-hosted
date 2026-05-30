#!/usr/bin/env node
/**
 * Provision Mini Data storage in the user's Cloudflare account.
 * Does NOT deploy the Mini Data application — UI stays at minidata.io.
 */
import { spawnSync } from "node:child_process";
import { randomBytes } from "node:crypto";
import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, "..");

function loadEnvFile() {
  const path = join(ROOT, ".env");
  if (!existsSync(path)) return;
  for (const line of readFileSync(path, "utf8").split("\n")) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    const val = trimmed.slice(eq + 1).trim();
    if (!process.env[key]) process.env[key] = val;
  }
}

function run(cmd, args, opts = {}) {
  const result = spawnSync(cmd, args, {
    cwd: ROOT,
    encoding: "utf8",
    stdio: opts.silent ? "pipe" : "inherit",
    env: { ...process.env, ...opts.env },
  });
  if (result.status !== 0) {
    const detail = result.stderr || result.stdout || "";
    throw new Error(`Command failed: ${cmd} ${args.join(" ")}\n${detail}`);
  }
  return result.stdout ?? "";
}

function parseJsonFromOutput(text) {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end === -1) return null;
  try {
    return JSON.parse(text.slice(start, end + 1));
  } catch {
    return null;
  }
}

function parseWorkersDevUrl(text) {
  const matches = text.match(/https:\/\/[^\s"'`]+\.workers\.dev/gi);
  return matches ? matches[matches.length - 1] : null;
}

function upsertWranglerToml({ databaseId, databaseName, r2Bucket }) {
  const example = join(ROOT, "wrangler.toml.example");
  const target = join(ROOT, "wrangler.toml");
  let content = existsSync(target)
    ? readFileSync(target, "utf8")
    : readFileSync(example, "utf8");

  content = content.replace(
    /database_id = ".*"/,
    `database_id = "${databaseId}"`,
  );
  content = content.replace(
    /database_name = ".*"/,
    `database_name = "${databaseName}"`,
  );

  if (r2Bucket && !content.includes("[[r2_buckets]]")) {
    content += `\n[[r2_buckets]]\nbinding = "FILES_BUCKET"\nbucket_name = "${r2Bucket}"\n`;
  } else if (r2Bucket) {
    content = content.replace(/bucket_name = ".*"/, `bucket_name = "${r2Bucket}"`);
  }

  writeFileSync(target, content, "utf8");
}

async function main() {
  loadEnvFile();

  const minidataOrigin = (process.env.MINIDATA_ORIGIN || "https://minidata.io").replace(/\/+$/, "");
  const databaseName = process.env.D1_DATABASE_NAME || "mini_data_db";
  const r2Bucket = process.env.R2_BUCKET_NAME || `minidata-files-${randomBytes(3).toString("hex")}`;
  const skipR2 = process.argv.includes("--no-r2");

  console.log("\nMini Data — self-hosted data plane provision");
  console.log("UI + app logic: minidata.io (your account owns D1/R2 only)\n");

  console.log("→ Checking Cloudflare authentication (wrangler whoami)…");
  const whoamiOut = run("npx", ["wrangler", "whoami"], { silent: true });
  const whoami = parseJsonFromOutput(whoamiOut);
  const accountId = whoami?.account_id || process.env.CLOUDFLARE_ACCOUNT_ID;
  if (!accountId) {
    throw new Error("Could not determine Cloudflare account id. Run `npx wrangler login` or set CLOUDFLARE_ACCOUNT_ID.");
  }
  console.log(`  Account: ${accountId}`);

  console.log(`→ Creating D1 database "${databaseName}"…`);
  const createDbOut = run("npx", ["wrangler", "d1", "create", databaseName], { silent: true });
  const createDb = parseJsonFromOutput(createDbOut);
  const databaseId = createDb?.uuid || createDb?.database_id;
  if (!databaseId) {
    throw new Error(`Could not parse D1 database id from wrangler output:\n${createDbOut}`);
  }
  console.log(`  Database id: ${databaseId}`);

  let bucketName = null;
  if (!skipR2) {
    console.log(`→ Creating R2 bucket "${r2Bucket}"…`);
    try {
      run("npx", ["wrangler", "r2", "bucket", "create", r2Bucket], { silent: true });
      bucketName = r2Bucket;
      console.log(`  Bucket: ${bucketName}`);
    } catch (err) {
      console.warn(`  R2 skipped (${err.message?.split("\n")[0] || "error"}). Re-run with --no-r2 or create bucket manually.`);
    }
  }

  if (!existsSync(join(ROOT, "wrangler.toml"))) {
    copyFileSync(join(ROOT, "wrangler.toml.example"), join(ROOT, "wrangler.toml"));
  }
  upsertWranglerToml({ databaseId, databaseName, r2Bucket: bucketName });

  console.log("→ Applying schema migrations to your D1 database…");
  run("npx", ["wrangler", "d1", "migrations", "apply", databaseName, "--remote"]);

  console.log("→ Deploying data worker to your Cloudflare account…");
  const deployOut = run("npx", ["wrangler", "deploy"], { silent: true });
  let dataUrl = (process.env.MINIDATA_DATA_URL || "").trim();
  if (!dataUrl) {
    const parsed = parseWorkersDevUrl(deployOut);
    if (parsed) dataUrl = parsed;
  }
  if (!dataUrl) {
    throw new Error(
      "Worker deployed but no URL found. Set MINIDATA_DATA_URL in .env (your workers.dev or custom domain URL).",
    );
  }
  if (!/^https?:\/\//i.test(dataUrl)) {
    dataUrl = `https://${dataUrl}`;
  }
  console.log(`  Data worker URL: ${dataUrl}`);

  const outDir = join(ROOT, ".minidata");
  mkdirSync(outDir, { recursive: true });
  const dataUrlPath = join(outDir, "data-url.txt");
  writeFileSync(dataUrlPath, `${dataUrl}\n`, "utf8");

  console.log("\n✓ Provision complete\n");
  console.log(`Data worker URL: ${dataUrl}`);
  console.log(`Saved to: ${dataUrlPath}`);
  console.log("\nNext steps:");
  console.log(`  1. Sign in at ${minidataOrigin}`);
  console.log("  2. Settings → Self-Hosted Data → paste your worker URL");
  console.log("     (workers.dev URL above, or a custom domain like data.yourdomain.com)");
  console.log("  3. Or run `npm run register` with MINIDATA_SESSION_COOKIE in .env\n");
  console.log("Optional: add a custom domain in Cloudflare Workers → your worker → Settings → Domains & Routes.\n");

  if (process.argv.includes("--register")) {
    console.log("→ Registering with Mini Data…");
    await import("./register.mjs");
  }
}

main().catch((err) => {
  console.error("\nProvision failed:", err.message || err);
  process.exit(1);
});
