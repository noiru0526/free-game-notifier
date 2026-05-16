/**
 * FCM (Firebase Cloud Messaging) notification utilities
 *
 * Sends push notifications to all users (topic-based)
 * when new free games are available.
 */

const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

/**
 * Send a push notification for a new free game offer
 * @param {Object} offer — enriched GameOffer with title, aiRecommendation, etc.
 */
async function sendFreeGameNotification(offer) {
  const messaging = admin.messaging();

  const title = `🎮 無料ゲーム追加: ${offer.title}`;
  const body = offer.aiRecommendation
    ? offer.aiRecommendation
    : `${offer.title}が期間限定で無料！今すぐチェックしよう。`;

  const message = {
    notification: { title, body },
    data: {
      offerId: offer.id ?? "",
      platform: offer.platform ?? "epic",
      offerEnd: offer.offerEnd ?? "",
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
          badge: 1,
        },
      },
    },
    android: {
      priority: "high",
      notification: {
        channelId: "free_games",
        priority: "high",
        defaultSound: true,
        defaultVibrateTimings: true,
        icon: "ic_notification",
        color: "#4E7CFF",
      },
    },
    // Send to topic — users subscribe to "free_games" topic
    topic: "free_games",
  };

  try {
    const resp = await messaging.send(message);
    logger.info(`FCM sent for ${offer.title}: ${resp}`);
    return resp;
  } catch (err) {
    logger.error(`FCM send failed for ${offer.title}:`, err.message);
    throw err;
  }
}

/**
 * Send expiry warning for games ending within 24 hours
 */
async function sendExpiryWarningNotification(offer) {
  const messaging = admin.messaging();
  const rem = offer.offerEnd
    ? Math.max(0, new Date(offer.offerEnd) - Date.now())
    : null;
  const hours = rem ? Math.floor(rem / 3600000) : 0;

  const message = {
    notification: {
      title: `⏰ まもなく終了: ${offer.title}`,
      body: `「${offer.title}」の無料配布があと${hours}時間で終了します！`,
    },
    data: {
      offerId: offer.id ?? "",
      platform: offer.platform ?? "epic",
      type: "expiry_warning",
    },
    android: {
      priority: "high",
      notification: {
        channelId: "expiry_warning",
        priority: "max",
      },
    },
    topic: "expiry_warnings",
  };

  try {
    const resp = await messaging.send(message);
    logger.info(`FCM expiry warning sent for ${offer.title}: ${resp}`);
    return resp;
  } catch (err) {
    logger.error(`FCM expiry warning failed for ${offer.title}:`, err.message);
    throw err;
  }
}

module.exports = { sendFreeGameNotification, sendExpiryWarningNotification };
