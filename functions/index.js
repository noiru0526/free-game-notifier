const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const { onSchedule } = require("firebase-functions/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const https = require("https");
const { enrichGameWithRAWG } = require("./rawg");
const { generateRecommendation } = require("./claude_recommend");
const { sendFreeGameNotification } = require("./fcm_notify");
const { fetchGOGFreeGames, fetchSteamFreeGames } = require("./gog_games");

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
    // API keys: set via Firebase Secrets or environment variables
    const rawgKey = process.env.RAWG_API_KEY ?? null;
    const anthropicKey = process.env.ANTHROPIC_API_KEY ?? null;
    // Default user genre preferences (overridable via Firestore config)
    const defaultGenres = ["Action", "RPG", "Indie", "Adventure"];

    try {
      const json = await fetchJSON(EPIC_API_URL);
      const offers = extractEpicOffers(json);
      logger.info(`Found ${offers.length} Epic offers`);

      const batch = db.batch();
      const recommendations = new Map();
      for (const offer of offers) {
        // Enrich with RAWG metadata if API key is available
        let rawgData = null;
        if (rawgKey && offer.status === "free") {
          rawgData = await enrichGameWithRAWG(offer.title, rawgKey);
          if (rawgData) logger.info(`RAWG enriched: ${offer.title}`);
        }

        // Generate Claude recommendation for free games
        let recommendation = null;
        if (anthropicKey && offer.status === "free") {
          try {
            recommendation = await generateRecommendation(
              { ...offer, metacritic: rawgData?.metacritic },
              defaultGenres,
              anthropicKey,
              "ja"
            );
            if (recommendation) {
              logger.info(`Claude rec generated: ${offer.title}`);
              recommendations.set(offer.id, recommendation);
            }
          } catch (recErr) {
            logger.warn(`Claude recommendation failed for ${offer.title}`, recErr.message);
          }
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
          ...(recommendation ? { aiRecommendation: recommendation } : {}),
        }, { merge: true });
      }
      await batch.commit();
      logger.info("Epic offers saved to Firestore");

      // Send FCM notifications for newly detected free games (skip already-notified)
      const freeOffers = offers.filter((o) => o.status === "free");
      for (const offer of freeOffers) {
        try {
          const docSnap = await db.collection("gameOffers").doc(`epic_${offer.id}`).get();
          if (docSnap.exists && docSnap.data()?.fcmNotifiedAt) {
            logger.info(`FCM already sent for ${offer.title}, skipping`);
            continue;
          }
          const enriched = {
            ...offer,
            aiRecommendation: recommendations.get(offer.id) ?? null,
          };
          await sendFreeGameNotification(enriched);
          await db.collection("gameOffers").doc(`epic_${offer.id}`).update({
            fcmNotifiedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          logger.info(`FCM notification sent for ${offer.title}`);
        } catch (fcmErr) {
          logger.warn(`FCM failed for ${offer.title}:`, fcmErr.message);
        }
      }
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

// ── Scheduled: expiry warning — runs every day at 09:00 UTC ───────────────
exports.sendExpiryWarnings = onSchedule(
  { schedule: "0 9 * * *", timeZone: "UTC", region: "asia-northeast1" },
  async () => {
    logger.info("Checking for expiring free games...");
    const { sendExpiryWarningNotification } = require("./fcm_notify");
    const now = Date.now();
    const in24h = now + 24 * 60 * 60 * 1000;

    try {
      const snap = await db
        .collection("gameOffers")
        .where("status", "==", "free")
        .get();

      for (const doc of snap.docs) {
        const data = doc.data();
        if (!data.offerEnd) continue;
        const endMs = new Date(data.offerEnd).getTime();
        if (endMs > now && endMs <= in24h && !data.expiryWarningSentAt) {
          try {
            await sendExpiryWarningNotification({ id: doc.id, ...data });
            await doc.ref.update({
              expiryWarningSentAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            logger.info(`Expiry warning sent for ${data.title}`);
          } catch (fcmErr) {
            logger.warn(`Expiry FCM failed for ${data.title}:`, fcmErr.message);
          }
        }
      }
    } catch (err) {
      logger.error("sendExpiryWarnings error", err);
    }
  }
);

// ── Scheduled: GOG + Steam free games (daily at 10:00 UTC) ──────────────────
exports.fetchOtherStoreFreeGames = onSchedule(
  { schedule: "0 10 * * *", timeZone: "UTC", region: "asia-northeast1" },
  async () => {
    logger.info("Fetching GOG and Steam free games...");
    try {
      const [gogGames, steamGames] = await Promise.all([
        fetchGOGFreeGames().catch((e) => { logger.warn("GOG fetch error:", e.message); return []; }),
        fetchSteamFreeGames().catch((e) => { logger.warn("Steam fetch error:", e.message); return []; }),
      ]);
      const allGames = [...gogGames, ...steamGames];
      logger.info(`GOG: ${gogGames.length}, Steam: ${steamGames.length} free games`);

      if (allGames.length === 0) return;
      const batch = db.batch();
      for (const game of allGames) {
        const ref = db.collection("gameOffers").doc(`${game.platform}_${game.id}`);
        batch.set(ref, {
          ...game,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }
      await batch.commit();
      logger.info(`Saved ${allGames.length} GOG/Steam offers to Firestore`);

      // Send FCM for new free games
      for (const game of allGames) {
        try {
          const docSnap = await db.collection("gameOffers").doc(`${game.platform}_${game.id}`).get();
          if (docSnap.exists && docSnap.data()?.fcmNotifiedAt) continue;
          await sendFreeGameNotification(game);
          await db.collection("gameOffers").doc(`${game.platform}_${game.id}`).update({
            fcmNotifiedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        } catch (fcmErr) {
          logger.warn(`FCM failed for ${game.title}:`, fcmErr.message);
        }
      }
    } catch (err) {
      logger.error("fetchOtherStoreFreeGames error", err);
    }
  }
);
