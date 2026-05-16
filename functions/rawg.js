/**
 * RAWG Video Games Database API utilities
 * https://rawg.io/apidocs
 *
 * Provides game metadata: screenshots, ratings, genres, metacritic score, etc.
 */

const https = require("https");

const RAWG_BASE = "https://api.rawg.io/api";

function rawgFetch(path, apiKey) {
  return new Promise((resolve, reject) => {
    const sep = path.includes("?") ? "&" : "?";
    const url = `${RAWG_BASE}${path}${sep}key=${apiKey}`;
    https
      .get(url, { headers: { "User-Agent": "free-game-notifier/1.0" } }, (res) => {
        let data = "";
        res.on("data", (c) => (data += c));
        res.on("end", () => {
          try {
            resolve(JSON.parse(data));
          } catch (e) {
            reject(new Error("RAWG JSON parse error: " + e.message));
          }
        });
      })
      .on("error", reject);
  });
}

/**
 * Search for a game by title and return enriched metadata
 * @param {string} title — game title from Epic API
 * @param {string} apiKey — RAWG API key (store in Firebase Secrets or env)
 * @returns {Object|null} RAWG game data or null if not found
 */
async function enrichGameWithRAWG(title, apiKey) {
  if (!apiKey) return null;

  try {
    const searchSlug = encodeURIComponent(title);
    const result = await rawgFetch(
      `/games?search=${searchSlug}&page_size=1&search_precise=true`,
      apiKey
    );

    const game = result.results?.[0];
    if (!game) return null;

    return {
      rawgId: game.id,
      metacritic: game.metacritic ?? null,
      rating: game.rating ?? null,
      ratingsCount: game.ratings_count ?? 0,
      released: game.released ?? null,
      backgroundImage: game.background_image ?? null,
      genres: (game.genres ?? []).map((g) => g.name),
      platforms: (game.platforms ?? []).map((p) => p.platform.name),
      tags: (game.tags ?? [])
        .slice(0, 5)
        .map((t) => t.name),
      website: game.website ?? null,
      playtime: game.playtime ?? null,
    };
  } catch (err) {
    console.error("RAWG enrichGameWithRAWG error:", err.message);
    return null;
  }
}

/**
 * Get screenshots for a game (by RAWG ID)
 */
async function getGameScreenshots(rawgId, apiKey) {
  if (!apiKey || !rawgId) return [];
  try {
    const result = await rawgFetch(`/games/${rawgId}/screenshots?page_size=4`, apiKey);
    return (result.results ?? []).map((s) => s.image);
  } catch {
    return [];
  }
}

module.exports = { enrichGameWithRAWG, getGameScreenshots };
