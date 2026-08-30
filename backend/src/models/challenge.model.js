const mongoose = require('mongoose');

const challengeSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: { type: String, required: true },
    domain: { type: String, required: true }, // e.g., "Energy Management"
    technology: { type: String, default: '' }, // e.g., "IoT & Analytics"
    outcome: { type: String, default: '' }, // e.g., "25% Cost Reduction"
    imageUrl: { type: String, default: '' },
    cloudinaryPublicId: { type: String, default: '' },
    status: { type: String, enum: ['Active', 'Draft'], default: 'Active' },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Challenge', challengeSchema);
