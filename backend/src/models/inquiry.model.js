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
      enum: [
        'Received',
        'Under Review',
        'Contacted',
        'In Discussion',
        'Completed',
        'Closed',
        'New',
        'In Progress',
        'Reviewed',
        'Resolved'
      ],
      default: 'Received',
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      index: true,
      default: null
    },
    firebaseUid: {
      type: String,
      index: true,
      default: null
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
    },
    responses: [
      {
        message: { type: String, required: true },
        subject: { type: String, default: '' },
        senderName: { type: String, default: 'Green Fusion Team' },
        senderRole: { type: String, default: 'admin' },
        sentAt: { type: Date, default: Date.now },
        emailSent: { type: Boolean, default: true },
        emailProvider: { type: String, default: '' },
        emailError: { type: String, default: '' }
      }
    ]
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
