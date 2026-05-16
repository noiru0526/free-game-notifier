/**
 * Claude API integration for game recommendation generation
 * https://docs.anthropic.com/ja/api
 *
 * Generates a personalized recommendation reason for each free game
 * based on user genre preferences.
 */

const https = require("https");

const CLAUDE_MODEL = "claude-haiku-4-5-20251001"; // fast and cheap for short text

/**
 * Generate a short recommendation reason for a game.
 *
 * @param {Object} offer — GameOffer object (title, description, genres, metacritic)
 * @param {string[]} userGenres — User's preferred genres from settings
 * @param {string} apiKey — Anthropic API key (Firebase Secret: ANTHROPIC_API_KEY)
 * @param {string} [lang="ja"] — Response language
 * @returns {Promise<string>} Recommendation text (1-2 sentences)
 */
async function generateRecommendation(offer, userGenres, apiKey, lang = "ja") {
  if (!apiKey) return null;

  const matchedGenres = offer.genres
    ? offer.genres.filter((g) =>
        userGenres.some((ug) => ug.toLowerCase() === g.toLowerCase())
      )
    : [];

  const prompt = lang === "ja"
    ? `ゲーム「${offer.title}」について、1〜2文で魅力的なおすすめ理由を書いてください。
ゲームの説明: ${offer.description || "なし"}
ジャンル: ${(offer.genres || []).join(", ") || "不明"}
${matchedGenres.length > 0 ? `ユーザーの好みジャンル（${matchedGenres.join(", ")}）に合致しています。` : ""}
${offer.metacritic ? `Metacriticスコア: ${offer.metacritic}` : ""}
期間限定で無料配布中であることを必ず含めてください。日本語で2文以内で答えてください。`
    : `Write 1-2 sentences recommending the free game "${offer.title}" (${(offer.genres || []).join(", ")}).
Description: ${offer.description || "N/A"}.
${offer.metacritic ? `Metacritic: ${offer.metacritic}.` : ""}
Mention it's temporarily free. Keep it concise and enthusiastic.`;

  const body = JSON.stringify({
    model: CLAUDE_MODEL,
    max_tokens: 200,
    messages: [{ role: "user", content: prompt }],
  });

  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: "api.anthropic.com",
        path: "/v1/messages",
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey,
          "anthropic-version": "2023-06-01",
          "Content-Length": Buffer.byteLength(body),
        },
      },
      (res) => {
        let data = "";
        res.on("data", (c) => (data += c));
        res.on("end", () => {
          try {
            const parsed = JSON.parse(data);
            const text = parsed.content?.[0]?.text ?? null;
            resolve(text);
          } catch (e) {
            reject(new Error("Claude API JSON parse error: " + e.message));
          }
        });
      }
    );
    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

module.exports = { generateRecommendation };
