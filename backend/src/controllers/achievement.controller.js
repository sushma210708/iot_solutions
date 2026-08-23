const Achievement = require('../models/achievement.model');

exports.createAchievement = async (req, res) => {
  try {
    const achievement = await Achievement.create(req.body);
    res.status(201).json({ success: true, data: achievement });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.getAchievements = async (req, res) => {
  try {
    const achievements = await Achievement.find().sort('-createdAt');
    res.status(200).json({ success: true, data: achievements });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.updateAchievement = async (req, res) => {
  try {
    const achievement = await Achievement.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!achievement) return res.status(404).json({ success: false, error: 'Achievement not found' });
    res.status(200).json({ success: true, data: achievement });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.deleteAchievement = async (req, res) => {
  try {
    const achievement = await Achievement.findByIdAndDelete(req.params.id);
    if (!achievement) return res.status(404).json({ success: false, error: 'Achievement not found' });
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};
