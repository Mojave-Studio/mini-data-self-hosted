/**
 * Data-plane worker stub — D1/R2 bindings live here in the customer's account.
 * Mini Data UI and auth stay at minidata.io; link this worker's URL in Settings.
 */
export default {
  async fetch(request) {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return Response.json({
        ok: true,
        service: "minidata-self-hosted-data-plane",
      });
    }

    return Response.json({
      ok: true,
      service: "minidata-self-hosted-data-plane",
      message:
        "Data resources are in your Cloudflare account. Open https://minidata.io and link this worker URL under Settings → Self-Hosted Data.",
      data_url: url.origin,
    });
  },
};
