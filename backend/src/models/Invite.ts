import mongoose, { Document, Schema } from 'mongoose';

export interface IInvite extends Document {
  token: string;
  phone: string;
  lenderId: mongoose.Types.ObjectId;
  loanId: mongoose.Types.ObjectId;
  expiresAt: Date;
  createdAt: Date;
}

const inviteSchema = new Schema<IInvite>({
  token: { type: String, required: true, unique: true },
  phone: { type: String, required: true, index: true },
  lenderId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  loanId: { type: Schema.Types.ObjectId, ref: 'Loan', required: true },
  expiresAt: { type: Date, required: true },
  createdAt: { type: Date, default: Date.now },
});

// Auto-delete expired invites
inviteSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

const Invite = mongoose.model<IInvite>('Invite', inviteSchema);
export default Invite;
