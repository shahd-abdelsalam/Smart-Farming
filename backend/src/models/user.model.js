import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
      minlength: 2,
      maxlength: 100,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    phoneNumber: {
      type: String,
      required: true,
      trim: true,
    },
    passwordHash: {
      type: String,
      required: true,
      select: false,
    },
    role: {
      type: String,
      enum: ["user", "admin"],
      default: "user",
    },
    language: {
      type: String,
      enum: ["en", "ar"],
      default: "en",
    },
    emailVerified: {
      type: Boolean,
      default: false,
    },
    profileImage: {
      type: String,
      default: "",
      trim: true,
    },
    notificationsEnabled: {
      type: Boolean,
      default: true,
    },
    lastLoginAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        delete ret.passwordHash;
        delete ret.__v;
        return ret;
      },
    },
    toObject: {
      transform: function (doc, ret) {
        delete ret.passwordHash;
        delete ret.__v;
        return ret;
      },
    },
    authProvider: {
    type: String,
    enum: ['local', 'google', 'facebook', 'apple', 'phone'],
    default: 'local'
    },
    providerId: {
    type: String
    },
    phone: {
    type: String
    }
  }
);

const User = mongoose.model("User", userSchema);

export default User;