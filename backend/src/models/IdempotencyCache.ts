import mongoose, { Document, Schema } from 'mongoose';

export interface IIdempotencyCache extends Document {
  key: string;
  userId: mongoose.Types.ObjectId;
  requestPath: string;
  responseBody: string;
  responseStatus: number;
  createdAt: Date;
}

const idempotencyCacheSchema = new Schema<IIdempotencyCache>({
  key: { type: String, required: true },
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  requestPath: { type: String, required: true },
  responseBody: { type: String, required: true },
  responseStatus: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now, expires: 86400 } // TTL 24 hours
});

// Ensure uniqueness per user and key combination
idempotencyCacheSchema.index({ key: 1, userId: 1 }, { unique: true });

const IdempotencyCache = mongoose.model<IIdempotencyCache>('IdempotencyCache', idempotencyCacheSchema);
export default IdempotencyCache;
