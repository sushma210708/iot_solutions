const mongoose = require('mongoose');

const aboutSchema = new mongoose.Schema(
  {
    heroTitle: { type: String, default: 'A technology company built on purpose and rigor.' },
    heroSubtitle: { type: String, default: 'We design and build technology that addresses real operational problems — not for demonstration, but for deployment.' },
    storyTitle: { type: String, default: 'Where we come from.' },
    storyDescription: { type: String, default: 'Our work is grounded in applied research, engineering discipline, and a commitment to solving problems that matter in the real world.' },
    storyImageUrl: { type: String, default: '' },
    visionTitle: { type: String, default: 'Technology that translates into real-world value.' },
    visionDescription: { type: String, default: 'Vision statement placeholder' },
    missionTitle: { type: String, default: 'To build with precision, purpose, and integrity.' },
    missionDescription: { type: String, default: 'Mission statement placeholder' },
    capabilitiesTitle: { type: String, default: 'Products and solutions designed for deployment.' },
    capabilitiesSubtitle: { type: String, default: 'We build across AI, computer vision, IoT, and digital platforms — always grounded in a real problem and a path to production.' },
    capabilities: [{
      title: String,
      description: String
    }]
  },
  { timestamps: true }
);

module.exports = mongoose.model('About', aboutSchema);
