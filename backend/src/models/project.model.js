const mongoose = require('mongoose');

const projectSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    category: { type: String, default: 'Engineering Solution' },
    shortDescription: { type: String, required: true },
    // 01 - The Challenge
    problem: { type: String, default: '' },
    // 02 - Why It Matters
    whyItMatters: { type: String, default: '' },
    // 03 - Our Solution
    solution: { type: String, default: '' },
    // 04 - How It Works
    workflowSteps: [
      {
        title: { type: String },
        description: { type: String }
      }
    ],
    // 05 - Key Capabilities
    keyCapabilities: [{ type: String }],
    // 06 - Impact
    impact: { type: String, default: '' },
    impactMetrics: [
      {
        metric: { type: String },
        value: { type: String },
        description: { type: String }
      }
    ],
    // 07 - Technology
    technologies: [{ type: String }],
    
    // Media
    imageUrl: { type: String, default: '' },
    cloudinaryPublicId: { type: String, default: '' },
    gallery: [
      {
        url: { type: String },
        cloudinaryPublicId: { type: String }
      }
    ],

    // Meta
    isFeatured: { type: Boolean, default: false },
    status: { type: String, enum: ['Active', 'Draft'], default: 'Active' },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Project', projectSchema);
