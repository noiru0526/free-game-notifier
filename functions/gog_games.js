/**
 * GOG.com free games fetcher
 * GOG offers "GOG Connect" and periodic free giveaways.
 * Uses GOG's public catalog API to detect free (price=0) games.
 */

const https = require("https");

function fetchJSON(url, options = {}) {
  return new Promise((resolve, reject) => {
    https
      .get(url, { headers: { "User-Agent": "free-game-notifier/1.0", ...options.headers } }, (res) => {
        let data = "";
        res.on("data", (c) => (data += c));
        res.on("end", () => {
          try { resolve(JSON.parse(data)); }
          catch (e) { reject(new Error("JSON parse error: " + e.message)); }
        });
      })
      .on("error", reject);
  });
}

// GOG public catalog API — filters for free games (price=0, currency=USD)
const GOG_FREE_URL =
  "https://catalog.gog.com/v1/catalog" +
  "?limit=20&order=desc%3Atrending&price=between%3A0%2C0&productType=in%3Agame";

async function fetchGOGFreeGames() {
  const json = await fetchJSON(GOG_FREE_URL);
  const products = json?.products ?? [];
  const now = new Date();

  return products.map((p) => {
    const price = p.price;
    const isFree = price?.finalMoney?.amount === "0.00" || price?.discountPercentage === 100;
    const originalPrice = parseFloat(price?.baseMoney?.amount ?? "0");
    const keyImage =
      p.coverHorizontal ?? p.coverVertical ?? null;

    return {
      id: String(p.id),
      title: p.title ?? "",
      description: p.description ?? "",
      platform: "gog",
      status: isFree ? "free" : "upcoming",
      originalPrice,
      thumbnailUrl: keyImage ? `https:${keyImage}` : null,
      genres: (p.genres ?? []).map((g) => g.name).filter(Boolean),
      offerStart: null,
      offerEnd: p.releaseDate ?? null,
      pageSlug: p.slug ?? null,
      updatedAt: now.toISOString(),
    };
  }).filter((g) => g.status === "free");
}

// Steam free-to-play and free weekend detection
// Uses SteamSpy API (public, no key required) + Steam store API
const STEAMSPY_FREE_URL = "https://steamspy.com/api.php?request=tag&tag=Free+to+Play&page=0";

async function fetchSteamFreeGames() {
  try {
    const json = await fetchJSON(STEAMSPY_FREE_URL);
    const games = Object.values(json ?? {}).slice(0, 10);
    return games.map((g) => ({
      id: String(g.appid),
      title: g.name ?? "",
      description: "",
      platform: "steam",
      status: "free",
      originalPrice: 0,
      thumbnailUrl: `https://cdn.akamai.steamstatic.com/steam/apps/${g.appid}/header.jpg`,
      genres: [],
      offerStart: null,
      offerEnd: null,
      pageSlug: String(g.appid),
      updatedAt: new Date().toISOString(),
    }));
  } catch {
    return [];
  }
}

module.exports = { fetchGOGFreeGames, fetchSteamFreeGames };
