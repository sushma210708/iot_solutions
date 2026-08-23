const mongoose = require('mongoose');

const heroContentSchema = new mongoose.Schema(
  {
    badge: {
      type: String,
      default: 'Smart IoT & AI Solutions',
    },
    titleLine1: {
      type: String,
      default: 'Build Smarter,',
    },
    titleLine2: {
      type: String,
      default: 'Live Better.',
    },
    description: {
      type: String,
      default: 'Technology solutions for agriculture, energy, water and industrial automation.',
    },
    imageUrl: {
      type: String,
      default: '',
    },
    cloudinaryPublicId: {
      type: String,
      default: '',
    }
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('HeroContent', heroContentSchema);
