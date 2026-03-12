import * as admin from 'firebase-admin';

// Initialize Firebase Admin
// In a real production app, you would pass the service account credentials here
// We are initializing with default credentials which works if the GOOGLE_APPLICATION_CREDENTIALS 
// environment variable is set or if running on GCP.
try {
  admin.initializeApp();
} catch (error) {
  console.warn('[NotificationService] Firebase Admin initialization failed or already initialized', error);
}

/**
 * Sends a push notification using Firebase Cloud Messaging
 */
export const sendPushNotification = async (fcmToken: string, title: string, body: string, data?: Record<string, string>) => {
  const message = {
    notification: {
      title,
      body,
    },
    data: data || {},
    token: fcmToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log(`[NotificationService] Sent FCM notification: ${response}`);
    return true;
  } catch (error) {
    console.error('[NotificationService] Error sending FCM notification:', error);
    return false;
  }
};
