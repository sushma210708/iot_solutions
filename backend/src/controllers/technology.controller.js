const Technology = require('../models/technology.model');

exports.getTechnology = async (req, res) => {
  try {
    let tech = await Technology.findOne();
    if (!tech) {
      tech = await Technology.create({});
    }
    res.json(tech);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.updateTechnology = async (req, res) => {
  try {
    let tech = await Technology.findOne();
    if (!tech) {
      tech = await Technology.create(req.body);
    } else {
      tech = await Technology.findOneAndUpdate({}, req.body, { new: true });
    }
    res.json(tech);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
