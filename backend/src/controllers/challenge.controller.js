const Challenge = require('../models/challenge.model');
const { deleteImage } = require('../services/cloudinaryService');

exports.getAllChallenges = async (req, res, next) => {
  try {
    const challenges = await Challenge.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: challenges.length, data: challenges });
  } catch (error) {
    next(error);
  }
};

exports.getChallengeById = async (req, res, next) => {
  try {
    const challenge = await Challenge.findById(req.params.id);
    if (!challenge) {
      return res.status(404).json({ success: false, message: 'Challenge not found' });
    }
    res.status(200).json({ success: true, data: challenge });
  } catch (error) {
    next(error);
  }
};

exports.createChallenge = async (req, res, next) => {
  try {
    const challenge = await Challenge.create(req.body);
    res.status(201).json({ success: true, data: challenge });
  } catch (error) {
    next(error);
  }
};

exports.updateChallenge = async (req, res, next) => {
  try {
    const challenge = await Challenge.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });
    if (!challenge) {
      return res.status(404).json({ success: false, message: 'Challenge not found' });
    }
    res.status(200).json({ success: true, data: challenge });
  } catch (error) {
    next(error);
  }
};

exports.deleteChallenge = async (req, res, next) => {
  try {
    const challenge = await Challenge.findById(req.params.id);
    if (!challenge) {
      return res.status(404).json({ success: false, message: 'Challenge not found' });
    }
    if (challenge.cloudinaryPublicId) {
      await deleteImage(challenge.cloudinaryPublicId);
    }
    await challenge.deleteOne();
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    next(error);
  }
};
