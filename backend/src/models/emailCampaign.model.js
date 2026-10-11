const mongoose = require('mongoose');

const emailCampaignSchema = new mongoose.Schema(
  {
    campaignId: {
      type: String,
      unique: true,
      index: true
    },
    subject: {
      type: String,
      required: true,
      trim: true
    },
    message: {
      type: String,
      required: true
    },
    emailType: {
      type: String,
      enum: ['announcement', 'service_update', 'project_update', 'newsletter', 'general'],
      default: 'announcement'
    },
    recipientType: {
      type: String,
      enum: ['all', 'selected', 'single'],
      default: 'all'
    },
    recipientCount: {
      type: Number,
      default: 0
    },
    recipients: [{
      email: { type: String, required: true },
      name: { type: String, default: '' },
      status: { type: String, enum: ['sent', 'failed'], default: 'sent' },
      error: { type: String, default: '' }
    }],
    sentBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    sentByName: {
      type: String,
      default: 'Administrator'
    },
    status: {
      type: String,
      enum: ['sent', 'partial_failure', 'failed'],
      default: 'sent'
    },
    stats: {
      total: { type: Number, default: 0 },
      successful: { type: Number, default: 0 },
      failed: { type: Number, default: 0 }
    }
  },
  {
    timestamps: true
  }
);

emailCampaignSchema.pre('save', function () {
  if (!this.campaignId) {
    const dateStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    this.campaignId = `CAMP-${dateStr}-${randomSuffix}`;
  }
});

module.exports = mongoose.model('EmailCampaign', emailCampaignSchema);
