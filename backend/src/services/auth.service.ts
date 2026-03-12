import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import User from '../models/User';
import RefreshToken from '../models/RefreshToken';
import Invite from '../models/Invite';
import Loan from '../models/Loan';

export class AuthService {
  static generateAccessToken(id: string): string {
    const secret = process.env.JWT_SECRET!;
    const expiresIn = '15m';
    return jwt.sign({ id }, secret, { expiresIn });
  }

  static async sendOtp(userId: string): Promise<void> {
    const user = await User.findById(userId);
    if (!user || !user.phone) throw new Error('User or phone number not found');
    
    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpiresAt = new Date();
    otpExpiresAt.setMinutes(otpExpiresAt.getMinutes() + 10);
    
    // In a real app, send OTP via Twilio/Firebase SMS here
    console.log(`[Mock SMS] Sending OTP ${otp} to ${user.phone}`);
    
    user.otp = otp;
    user.otpExpiresAt = otpExpiresAt;
    await user.save();
  }

  static async verifyOtp(userId: string, otp: string): Promise<boolean> {
    const user = await User.findById(userId).select('+otp +otpExpiresAt');
    if (!user) throw new Error('User not found');
    
    if (user.isPhoneVerified) return true;

    if (!user.otp || !user.otpExpiresAt) throw new Error('No OTP requested');
    if (new Date() > user.otpExpiresAt) throw new Error('OTP expired');
    if (user.otp !== otp) throw new Error('Invalid OTP');

    user.isPhoneVerified = true;
    user.otp = undefined;
    user.otpExpiresAt = undefined;
    await user.save();

    return true;
  }

  static async generateRefreshTokenRecord(userId: string): Promise<string> {
    const token = uuidv4();
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await RefreshToken.create({
      token,
      userId,
      expiresAt,
    });

    return token;
  }

  static async registerUser(data: any) {
    const { name, email, phone, password } = data;

    const existing = await User.findOne({
      $or: [email ? { email } : {}, phone ? { phone } : {}].filter(
        (q) => Object.keys(q).length > 0
      ),
    });

    if (existing) {
      throw new Error('User already exists with this email or phone');
    }

    const user = await User.create({
      name,
      email,
      phone,
      passwordHash: password,
    });

    // Handle pending invites
    if (phone) {
      const pendingInvites = await Invite.find({ phone });
      if (pendingInvites.length > 0) {
        const loanIds = pendingInvites.map((invite) => invite.loanId);
        await Loan.updateMany({ _id: { $in: loanIds } }, { $set: { borrowerId: user._id } });
        await Invite.deleteMany({ phone });
      }
    }

    const token = this.generateAccessToken(user._id.toString());
    const refreshToken = await this.generateRefreshTokenRecord(user._id.toString());

    return { user, token, refreshToken };
  }

  static async loginUser(data: any) {
    const { email, phone, password } = data;
    const query = email ? { email } : { phone };
    const user = await User.findOne(query).select('+passwordHash');

    if (!user) throw new Error('Invalid credentials');
    
    const isMatch = await user.comparePassword(password);
    if (!isMatch) throw new Error('Invalid credentials');

    const token = this.generateAccessToken(user._id.toString());
    const refreshToken = await this.generateRefreshTokenRecord(user._id.toString());

    return { user, token, refreshToken };
  }

  static async refreshAuth(refreshTokenStr: string) {
    const tokenRecord = await RefreshToken.findOne({ token: refreshTokenStr });
    if (!tokenRecord) throw new Error('Invalid refresh token');

    if (new Date() > tokenRecord.expiresAt) {
      await tokenRecord.deleteOne();
      throw new Error('Refresh token expired');
    }

    const user = await User.findById(tokenRecord.userId);
    if (!user) throw new Error('User not found');

    const newToken = this.generateAccessToken(user._id.toString());
    const newRefreshToken = await this.generateRefreshTokenRecord(user._id.toString());
    
    await tokenRecord.deleteOne();

    return { token: newToken, refreshToken: newRefreshToken };
  }

  static async logoutUser(refreshToken?: string) {
    if (refreshToken) {
      await RefreshToken.deleteOne({ token: refreshToken });
    }
  }
}
