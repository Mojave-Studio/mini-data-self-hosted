#!/usr/bin/env node
/**
 * Register your deployed data worker URL with minidata.io.
 */
import { readFileSync, existsSync } from "node:fs";
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

function resolveDataUrl() {
  if (process.env.MINIDATA_DATA_URL?.trim()) {
    return process.env.MINIDATA_DATA_URL.trim();
  }
  const urlPath = join(ROOT, ".minidata", "data-url.txt");
  if (existsSync(urlPath)) {
    return readFileSync(urlPath, "utf8").trim();
  }
  return "";
}

async function main() {
  loadEnvFile();

  const dataUrl = resolveDataUrl();
  const origin = (process.env.MINIDATA_ORIGIN || "https://minidata.io").replace(/\/+$/, "");
  const sessionCookie = process.env.MINIDATA_SESSION_COOKIE;

  if (!dataUrl) {
    throw new Error(
      "No data worker URL found. Run `npm run provision` first or set MINIDATA_DATA_URL in .env",
    );
  }

  if (!sessionCookie) {
    console.log("\nTo register from CLI, set MINIDATA_SESSION_COOKIE in .env");
    console.log("(copy the `session` cookie after signing in at minidata.io)\n");
    console.log("Or paste this URL in the Mini Data UI: Settings → Self-Hosted Data\n");
    console.log(dataUrl);
    console.log("");
    process.exit(0);
  }

  const res = await fetch(`${origin}/api/self-hosted/register`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      cookie: `session=${sessionCookie}`,
    },
    body: JSON.stringify({ data_url: dataUrl }),
  });

  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(data.error || `Registration failed (${res.status})`);
  }

  console.log("\n✓ Linked to Mini Data account");
  console.log(`  Data worker: ${data.data_url || dataUrl}`);
  console.log(`  Open ${origin} to use the app with your self-hosted data.\n`);
}

main().catch((err) => {
  console.error("\nRegister failed:", err.message || err);
  process.exit(1);
});
