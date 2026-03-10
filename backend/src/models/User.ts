import mongoose, { Document, Schema, CallbackWithoutResultAndOptionalError } from 'mongoose';
import bcrypt from 'bcryptjs';

export interface IUser extends Document {
  _id: mongoose.Types.ObjectId;
  name: string;
  email?: string;
  phone?: string;
  passwordHash: string;
  trustScore: number;
  profilePicture?: string;
  pushToken?: string;
  createdAt: Date;
  updatedAt: Date;
  comparePassword(candidatePassword: string): Promise<boolean>;
}

const userSchema = new Schema<IUser>(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      maxlength: [100, 'Name cannot exceed 100 characters'],
    },
    email: {
      type: String,
      unique: true,
      sparse: true,
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Please enter a valid email'],
    },
    phone: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
    },
    passwordHash: {
      type: String,
      required: true,
      minlength: 6,
      select: false,
    },
    trustScore: {
      type: Number,
      default: 50,
      min: 0,
      max: 100,
    },
    profilePicture: {
      type: String,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret: Record<string, unknown>) => {
        ret['passwordHash'] = undefined;
        return ret;
      },
    },
  }
);

// Mongoose 7+ pre-save callback is typed as CallbackWithoutResultAndOptionalError
userSchema.pre('save', async function () {
  const self = this as any;
  if (!self.isModified('passwordHash')) {
    return;
  }
  const salt = await bcrypt.genSalt(12);
  self.passwordHash = await bcrypt.hash(self.passwordHash, salt);
});

// Ensure at least one contact method
userSchema.pre('validate', async function () {
  const self = this as any;
  if (!self.email && !self.phone) {
    self.invalidate('email', 'Either email or phone is required');
  }
});

userSchema.methods['comparePassword'] = async function (
  candidatePassword: string
): Promise<boolean> {
  const self = this as any;
  return bcrypt.compare(candidatePassword, self.passwordHash as string);
};

const User = mongoose.model<IUser>('User', userSchema);
export default User;
