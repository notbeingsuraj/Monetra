import mongoose, { Document, Schema } from 'mongoose';

export type LoanStatus = 'pending' | 'repaid' | 'overdue' | 'defaulted';

export interface ILoan extends Document {
  _id: mongoose.Types.ObjectId;
  lenderId: mongoose.Types.ObjectId;
  borrowerName: string;
  borrowerContact?: string;
  borrowerId?: mongoose.Types.ObjectId;
  amount: number;
  currency: string;
  dueDate: Date;
  note?: string;
  status: LoanStatus;
  repaidAt?: Date;
  lateDays: number;
  createdAt: Date;
  updatedAt: Date;
}

const loanSchema = new Schema<ILoan>(
  {
    lenderId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    borrowerName: {
      type: String,
      required: [true, 'Borrower name is required'],
      trim: true,
      maxlength: 100,
    },
    borrowerContact: {
      type: String,
      trim: true,
    },
    borrowerId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    amount: {
      type: Number,
      required: [true, 'Loan amount is required'],
      min: [0.01, 'Amount must be greater than 0'],
    },
    currency: {
      type: String,
      default: 'INR',
      uppercase: true,
      maxlength: 3,
    },
    dueDate: {
      type: Date,
      required: [true, 'Due date is required'],
    },
    note: {
      type: String,
      trim: true,
      maxlength: 500,
    },
    status: {
      type: String,
      enum: ['pending', 'repaid', 'overdue', 'defaulted'],
      default: 'pending',
    },
    repaidAt: {
      type: Date,
      default: null,
    },
    lateDays: {
      type: Number,
      default: 0,
      min: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Calculate overdue status automatically
loanSchema.virtual('isOverdue').get(function () {
  return this.status === 'pending' && new Date() > this.dueDate;
});

loanSchema.index({ lenderId: 1, status: 1 });
loanSchema.index({ dueDate: 1 });

const Loan = mongoose.model<ILoan>('Loan', loanSchema);
export default Loan;
