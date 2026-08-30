const mongoose = require('mongoose');

const testimonialSchema = new mongoose.Schema(
  {
    quote: { type: String, required: true },
    organization: { type: String, required: true },
    personName: { type: String, required: true },
    designation: { type: String, default: '' },
    status: { type: String, enum: ['Active', 'Draft'], default: 'Active' },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Testimonial', testimonialSchema);
