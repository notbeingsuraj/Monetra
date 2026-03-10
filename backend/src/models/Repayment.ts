import mongoose, { Document, Schema } from 'mongoose';

export interface IRepayment extends Document {
  _id: mongoose.Types.ObjectId;
  loanId: mongoose.Types.ObjectId;
  lenderId: mongoose.Types.ObjectId;
  amountPaid: number;
  note?: string;
  paidAt: Date;
  createdAt: Date;
}

const repaymentSchema = new Schema<IRepayment>(
  {
    loanId: {
      type: Schema.Types.ObjectId,
      ref: 'Loan',
      required: true,
      index: true,
    },
    lenderId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    amountPaid: {
      type: Number,
      required: [true, 'Payment amount is required'],
      min: [0.01, 'Amount must be greater than zero'],
    },
    note: {
      type: String,
      trim: true,
      maxlength: 300,
    },
    paidAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

const Repayment = mongoose.model<IRepayment>('Repayment', repaymentSchema);
export default Repayment;
