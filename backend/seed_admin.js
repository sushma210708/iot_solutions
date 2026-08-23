require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/user.model');
const dns = require('dns');

// Force Node.js to use Google DNS
dns.setServers(['8.8.8.8', '8.8.4.4']);

const seedAdmin = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB Connected');

    // Replace this with your actual Firebase UID from the Firebase Console -> Authentication tab
    const yourFirebaseUid = '0BkTH1zOW7S6AYNrUHzCeywgkOz1'; 

    const existingUser = await User.findOne({ firebaseUid: yourFirebaseUid });
    if (existingUser) {
      console.log('User already exists! Making them a super_admin...');
      existingUser.role = 'super_admin';
      existingUser.status = 'active';
      existingUser.permissions = ['manage_projects', 'manage_achievements', 'manage_mentors', 'manage_homepage', 'manage_gallery', 'view_users', 'manage_admins'];
      await existingUser.save();
      console.log('Successfully updated existing user to super_admin!');
    } else {
      console.log('Creating new super_admin user...');
      await User.create({
        firebaseUid: yourFirebaseUid,
        name: 'Super Admin',
        email: 'admin@greenfusion.com', // Change to your email
        role: 'super_admin',
        status: 'active',
        permissions: ['manage_projects', 'manage_achievements', 'manage_mentors', 'manage_homepage', 'manage_gallery', 'view_users', 'manage_admins']
      });
      console.log('Successfully created the first super_admin!');
    }

    process.exit(0);
  } catch (error) {
    console.error('Seeding failed:', error);
    process.exit(1);
  }
};

seedAdmin();
