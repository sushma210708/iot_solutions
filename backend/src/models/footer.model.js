const mongoose = require('mongoose');

const footerSchema = new mongoose.Schema({
  companyDescription: { type: String, default: 'Revolutionizing energy management through IoT and AI-powered solutions.' },
  email: { type: String, default: 'info@gfiotsolutions.com' },
  phone1: { type: String, default: '+91 6301644960' },
  phone2: { type: String, default: '+91 9398633736' },
  phone3: { type: String, default: '+91 9951012333' },
  instagram: { type: String, default: '@greenfusioniotsolutions' },
  aboutTeam: { type: String, default: 'Our team of experts combines deep industry knowledge with cutting-edge technology expertise to deliver innovative energy solutions.' }
}, { timestamps: true });

module.exports = mongoose.model('Footer', footerSchema);
