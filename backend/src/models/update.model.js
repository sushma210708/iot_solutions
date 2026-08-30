const mongoose = require('mongoose');

const updateSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    shortDescription: { type: String, required: true },
    fullContent: { type: String, default: '' },
    imageUrl: { type: String, default: '' },
    cloudinaryPublicId: { type: String, default: '' },
    category: { type: String, default: 'General' },
    status: { type: String, enum: ['Draft', 'Published'], default: 'Draft' },
    notifySubscribers: { type: Boolean, default: false },
    notificationSent: { type: Boolean, default: false },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Update', updateSchema);
