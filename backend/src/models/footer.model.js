const mongoose = require('mongoose');

const footerSchema = new mongoose.Schema({
  companyName: { 
    type: String, 
    default: 'Green Fusion IoT Solutions' 
  },
  companyDescription: { 
    type: String, 
    default: 'Revolutionizing energy management through IoT and AI-powered solutions.' 
  },
  address: {
    type: String,
    default: 'Plot No. 42, Green Tech Park, Hyderabad, India'
  },
  businessHours: {
    type: String,
    default: 'Mon - Fri: 9:00 AM - 6:00 PM IST'
  },
  copyrightText: {
    type: String,
    default: '© 2026 GreenFusion IoT Solutions. All rights reserved.'
  },
  phones: {
    type: [String],
    default: ['+91 6301644960', '+91 9398633736', '+91 9951012333']
  },
  emails: {
    type: [String],
    default: ['info@gfiotsolutions.com', 'contact@gfiotsolutions.com']
  },
  socialLinks: [{
    platform: { type: String, required: true }, // e.g. instagram, linkedin, twitter, github, youtube
    url: { type: String, default: '' },
    label: { type: String, default: '' }
  }],
  quickLinks: [{
    label: { type: String, required: true },
    route: { type: String, required: true }
  }],
  servicesLinks: [{
    label: { type: String, required: true },
    route: { type: String, required: true }
  }],
  aboutTeam: { 
    type: String, 
    default: 'Our team of experts combines deep industry knowledge with cutting-edge technology expertise to deliver innovative energy solutions.' 
  },

  // Backwards compatibility legacy fields
  phone1: { type: String, default: '+91 6301644960' },
  phone2: { type: String, default: '+91 9398633736' },
  phone3: { type: String, default: '+91 9951012333' },
  email: { type: String, default: 'info@gfiotsolutions.com' },
  instagram: { type: String, default: '@greenfusioniotsolutions' }
}, { timestamps: true });

// Pre-save hook to synchronize legacy fields and array fields
footerSchema.pre('save', function () {
  if (this.phones && this.phones.length > 0) {
    this.phone1 = this.phones[0] || '';
    this.phone2 = this.phones[1] || '';
    this.phone3 = this.phones[2] || '';
  }
  if (this.emails && this.emails.length > 0) {
    this.email = this.emails[0] || '';
  }
});

module.exports = mongoose.model('Footer', footerSchema);
