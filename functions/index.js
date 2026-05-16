const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const { onSchedule } = require("firebase-functions/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const https = require("https");
const { enrichGameWithRAWG } = require("./rawg");

admin.initializeApp();
const db = admin.firestore();

setGlobalOptions({ maxInstances: 10, region: "asia-northeast1" });

// ── Epic Games Free Games API ──────────────────────────────────────────────
const EPIC_API_URL =
  "https://store-site-backend-static.ak.epicgames.com/freeGamesPromotions" +
  "?locale=ja&country=JP&allowCountries=JP";

function fetchJSON(url) {
  return new Promise((resolve, reject) => {
    https
      .get(url, { headers: { "User-Agent": "free-game-notifier/1.0" } }, (res) => {
        let data = "";
        res.on("data", (c) => (data += c));
        res.on("end", () => {
          try {
            resolve(JSON.parse(data));
          } catch (e) {
            reject(new Error("JSON parse error: " + e.message));
          }
        });
      })
      .on("error", reject);
  });
}

function extractEpicOffers(json) {
  const elements =
    json?.data?.Catalog?.searchStore?.elements ?? [];
  const now = new Date();
  const offers = [];

  for (const el of elements) {
    const promo = el.promotions;
    if (!promo) continue;

    // Current free period
    const currentOffers = promo.promotionalOffers?.[0]?.promotionalOffers ?? [];
    // Upcoming free period
    const upcomingOffers = promo.upcomingPromotionalOffers?.[0]?.promotionalOffers ?? [];

    for (const offer of [...currentOffers, ...upcomingOffers]) {
      if (offer.discountSetting?.discountPercentage !== 0) continue;
      const startDate = new Date(offer.startDate);
      const endDate = new Date(offer.endDate);
      const isCurrent = startDate <= now && now < endDate;
      const isUpcoming = startDate > now;

      const originalPrice =
        el.price?.totalPrice?.originalPrice ?? 0;
      const keyImage =
        el.keyImages?.find((img) => img.type === "Thumbnail")?.url ??
        el.keyImages?.[0]?.url ??
        null;

      offers.push({
        id: el.id,
        title: el.title,
        description: el.description ?? "",
        platform: "epic",
        status: isCurrent ? "free" : isUpcoming ? "upcoming" : "expired",
        originalPrice: originalPrice / 100,
        thumbnailUrl: keyImage,
        genres: (el.categories ?? []).map((c) => c.path).filter(Boolean),
        offerStart: offer.startDate,
        offerEnd: offer.endDate,
        pageSlug:
          el.catalogNs?.mappings?.[0]?.pageSlug ??
          el.urlSlug ??
          null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }
  return offers;
}

// ── Scheduled: every Thursday at 18:00 JST (09:00 UTC) ────────────────────
exports.fetchEpicFreeGames = onSchedule(
  { schedule: "0 9 * * 4", timeZone: "UTC", region: "asia-northeast1" },
  async () => {
    logger.info("Fetching Epic Games free promotions...");
    // RAWG API key: set via Firebase Secret or environment variable
    const rawgKey = process.env.RAWG_API_KEY ?? null;

    try {
      const json = await fetchJSON(EPIC_API_URL);
      const offers = extractEpicOffers(json);
      logger.info(`Found ${offers.length} Epic offers`);

      const batch = db.batch();
      for (const offer of offers) {
        // Enrich with RAWG metadata if API key is available
        let rawgData = null;
        if (rawgKey && offer.status === "free") {
          rawgData = await enrichGameWithRAWG(offer.title, rawgKey);
          if (rawgData) logger.info(`RAWG enriched: ${offer.title}`);
        }

        const ref = db.collection("gameOffers").doc(`epic_${offer.id}`);
        batch.set(ref, {
          ...offer,
          ...(rawgData ? {
            metacritic: rawgData.metacritic,
            rating: rawgData.rating,
            backgroundImage: rawgData.backgroundImage,
            rawgGenres: rawgData.genres,
            rawgTags: rawgData.tags,
            released: rawgData.released,
            playtime: rawgData.playtime,
          } : {}),
        }, { merge: true });
      }
      await batch.commit();
      logger.info("Epic offers saved to Firestore");
    } catch (err) {
      logger.error("fetchEpicFreeGames error", err);
    }
  }
);

// ── HTTP trigger: manual fetch (for testing) ─────────────────────────────
exports.fetchEpicNow = onRequest(
  { region: "asia-northeast1" },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed — use POST");
      return;
    }
    try {
      const json = await fetchJSON(EPIC_API_URL);
      const offers = extractEpicOffers(json);
      logger.info(`Manual fetch: ${offers.length} Epic offers`);

      const batch = db.batch();
      for (const offer of offers) {
        const ref = db.collection("gameOffers").doc(`epic_${offer.id}`);
        batch.set(ref, offer, { merge: true });
      }
      await batch.commit();

      res.status(200).json({
        success: true,
        count: offers.length,
        offers: offers.map((o) => ({
          id: o.id,
          title: o.title,
          status: o.status,
          offerEnd: o.offerEnd,
        })),
      });
    } catch (err) {
      logger.error("fetchEpicNow error", err);
      res.status(500).json({ success: false, error: String(err) });
    }
  }
);

// ── HTTP trigger: get current free games from Firestore ───────────────────
exports.getFreeGames = onRequest(
  { region: "asia-northeast1", cors: true },
  async (req, res) => {
    try {
      const snap = await db
        .collection("gameOffers")
        .where("status", "in", ["free", "upcoming"])
        .orderBy("offerEnd", "asc")
        .limit(20)
        .get();

      const games = snap.docs.map((doc) => ({ docId: doc.id, ...doc.data() }));
      res.status(200).json({ success: true, count: games.length, games });
    } catch (err) {
      logger.error("getFreeGames error", err);
      res.status(500).json({ success: false, error: String(err) });
    }
  }
);
