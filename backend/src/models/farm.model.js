import mongoose from "mongoose";

const farmSchema = new mongoose.Schema(
  {
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
    },

    name: {
      type: String,
      default: "",
      trim: true,
    },

    locationText: {
      type: String,
      default: "",
      trim: true,
    },

    geo: {
      lat: {
        type: Number,
        default: null,
      },
      lng: {
        type: Number,
        default: null,
      },
    },

    farmSize: {
      type: String,
      required: true,
      trim: true,
    },

    cropTypes: {
      type: String,
      required: true,
      trim: true,
    },

    soilType: {
      type: String,
      required: true,
      trim: true,
    },

    irrigationType: {
      type: String,
      required: true,
      trim: true,
    },

    plantingDate: {
      type: Date,
      required: true,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: function (doc, ret) {
        delete ret.__v;
        return ret;
      },
    },
    toObject: {
      transform: function (doc, ret) {
        delete ret.__v;
        return ret;
      },
    },
  }
);

const Farm = mongoose.model("Farm", farmSchema);

export default Farm;