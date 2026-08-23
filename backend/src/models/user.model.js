const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    firebaseUid: {
      type: String,
      required: true,
      unique: true,
    },
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    role: {
      type: String,
      enum: ['super_admin', 'content_admin', 'viewer'],
      default: 'viewer',
    },
    permissions: [{
      type: String,
      enum: [
        'manage_projects',
        'manage_achievements',
        'manage_mentors',
        'manage_homepage',
        'manage_gallery',
        'view_users',
        'manage_admins'
      ]
    }],
    status: {
      type: String,
      enum: ['active', 'disabled'],
      default: 'active',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('User', userSchema);
