const mongoose = require('mongoose');

const productSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    shortTitle: { type: String, default: '' },
    category: { type: String, required: true },
    shortDescription: { type: String, required: true },
    detailedDescription: { type: String, default: '' },
    benefits: [{ type: String }],
    specifications: [{ parameter: String, value: String }],
    parameters: [{ type: String }],
    technologies: [{ type: String }],
    year: { type: String, default: '' },
    status: { type: String, enum: ['Active', 'Draft'], default: 'Active' },
    images: [{ url: String, cloudinaryPublicId: String }],
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Product', productSchema);
