import cron from 'node-cron';
import Loan from '../models/Loan';
import User from '../models/User';
import { sendPushNotification } from './notification.service';

/**
 * Updates overdue status daily for all pending loans that have passed their due date.
 */
export const startReminderService = (): void => {
  // Run every day at 8:00 AM
  cron.schedule('0 8 * * *', async () => {
    console.log('[ReminderService] Running daily overdue check...');
    const now = new Date();

    const overdueLoans = await Loan.find({
      status: 'pending',
      dueDate: { $lt: now },
    });

    for (const loan of overdueLoans) {
      const diffMs = now.getTime() - loan.dueDate.getTime();
      const lateDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
      
      await Loan.findByIdAndUpdate(loan._id, {
        status: 'overdue',
        lateDays,
      });

      // Notify the lender
      try {
        const lender = await User.findById(loan.lenderId);
        if (lender && lender.pushToken) {
          await sendPushNotification(
            lender.pushToken,
            'Loan Overdue! ⚠️',
            `The loan of $${loan.amount} from ${loan.borrowerName} is now overdue.`
          );
        }
      } catch (error) {
        console.error(`[ReminderService] Failed to notify lender for loan ${loan._id}:`, error);
      }
    }

    console.log(`[ReminderService] Marked ${overdueLoans.length} loans as overdue.`);
  });

  // Also check for upcoming deadlines (1 day before)
  cron.schedule('0 9 * * *', async () => {
    console.log('[ReminderService] Running daily upcoming deadline check...');
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);

    const afterTomorrow = new Date(tomorrow);
    afterTomorrow.setDate(afterTomorrow.getDate() + 1);

    const upcomingLoans = await Loan.find({
      status: 'pending',
      dueDate: { $gte: tomorrow, $lt: afterTomorrow },
    });

    for (const loan of upcomingLoans) {
      try {
        const lender = await User.findById(loan.lenderId);
        if (lender && lender.pushToken) {
          await sendPushNotification(
            lender.pushToken,
            'Repayment Reminder 📅',
            `${loan.borrowerName} owes you $${loan.amount} tomorrow.`
          );
        }
      } catch (error) {
        console.error(`[ReminderService] Failed to notify lender for upcoming loan ${loan._id}:`, error);
      }
    }
  });
};
