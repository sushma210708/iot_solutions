const About = require('../models/about.model');

exports.getAbout = async (req, res, next) => {
  try {
    let about = await About.findOne();
    if (!about) {
      about = await About.create({
        capabilities: [
          { title: 'AI & Machine Learning', description: 'Supervised and unsupervised learning pipelines, NLP, model deployment and monitoring.' },
          { title: 'Computer Vision', description: 'Object detection, classification, segmentation, and edge inference.' },
          { title: 'IoT & Embedded Systems', description: 'Sensor integration, firmware, MQTT pipelines, and real-time telemetry.' },
          { title: 'Cloud Platforms', description: 'AWS, GCP, and Azure architecture — scalable, cost-efficient infrastructure.' }
        ]
      });
    }
    res.status(200).json({ success: true, data: about });
  } catch (error) {
    next(error);
  }
};

exports.updateAbout = async (req, res, next) => {
  try {
    let about = await About.findOne();
    if (!about) {
      about = await About.create({});
    }

    about = await About.findByIdAndUpdate(about._id, req.body, {
      new: true,
      runValidators: true
    });

    res.status(200).json({ success: true, data: about });
  } catch (error) {
    next(error);
  }
};
