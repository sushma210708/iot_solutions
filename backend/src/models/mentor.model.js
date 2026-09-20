const mongoose = require('mongoose');

const mentorSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  role: {
    type: String,
    required: true,
  },
  imageUrl: {
    type: String,
    default: '',
  },
  cloudinaryPublicId: {
    type: String,
    default: '',
  },
  bio: {
    type: String,
    default: '',
  },
  contributions: {
    type: [String],
    default: [],
  }
}, { timestamps: true });

module.exports = mongoose.model('Mentor', mentorSchema);
