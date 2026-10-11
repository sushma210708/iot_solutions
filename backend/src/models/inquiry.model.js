const mongoose = require('mongoose');

const inquirySchema = new mongoose.Schema(
  {
    inquiryId: {
      type: String,
      unique: true,
      index: true
    },
    name: {
      type: String,
      required: [true, 'Please provide your full name'],
      trim: true,
    },
    email: {
      type: String,
      required: [true, 'Please provide your email address'],
      trim: true,
      lowercase: true,
    },
    phone: {
      type: String,
      required: [true, 'Please provide your phone number'],
      trim: true,
    },
    message: {
      type: String,
      required: [true, 'Please describe your project requirements'],
      trim: true,
    },
    status: {
      type: String,
      enum: ['New', 'Contacted', 'In Progress', 'Closed', 'Reviewed', 'Resolved'], // Includes legacy statuses for migration
      default: 'New',
    },
    internalNotes: {
      type: String,
      default: '',
    },
    emailNotification: {
      sent: { type: Boolean, default: false },
      provider: { type: String, default: '' },
      recipient: { type: String, default: '' },
      sentAt: { type: Date },
      error: { type: String, default: '' }
    }
  },
  {
    timestamps: true,
  }
);

// Auto-generate inquiry ID before saving if not present
inquirySchema.pre('save', function () {
  if (!this.inquiryId) {
    const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    this.inquiryId = `GF-${dateStr}-${randomSuffix}`;
  }
});

module.exports = mongoose.model('Inquiry', inquirySchema);
