const mongoose = require('mongoose');

const technologySchema = new mongoose.Schema({
  headerTitle: { type: String, default: 'TECHNOLOGY' },
  mainTitle: { type: String, default: 'The technology domains we operate in.' },
  mainSubtitle: { type: String, default: 'We build across a range of technology disciplines — applying the right tools and approaches for the problem at hand.' },
  coreDomainsHeader: { type: String, default: 'CORE DOMAINS' },
  coreDomainsTitle: { type: String, default: 'Primary areas of technical depth.' },
  domains: [{
    title: String,
    description: String,
    bullets: [String],
    imageUrl: String
  }]
}, { timestamps: true });

module.exports = mongoose.model('Technology', technologySchema);
