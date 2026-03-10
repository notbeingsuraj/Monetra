import axios from 'axios';

/**
 * Sends a push notification using Expo Push API
 */
export const sendPushNotification = async (expoPushToken: string, title: string, body: string, data?: any) => {
  const message = {
    to: expoPushToken,
    sound: 'default',
    title,
    body,
    data: data || {},
  };

  try {
    await axios.post('https://exp.host/--/api/v2/push/send', message, {
      headers: {
        Accept: 'application/json',
        'Accept-encoding': 'gzip, deflate',
        'Content-Type': 'application/json',
      },
    });
    console.log(`[NotificationService] Sent notification to ${expoPushToken}`);
  } catch (error) {
    console.error('[NotificationService] Error sending push notification:', error);
  }
};
