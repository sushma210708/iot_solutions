const HeroContent = require('../models/hero.model');

// @desc    Get hero content
// @route   GET /api/hero
// @access  Public
exports.getHeroContent = async (req, res, next) => {
  try {
    let hero = await HeroContent.findOne();
    if (!hero) {
      hero = await HeroContent.create({}); // Create default if none exists
    }
    res.status(200).json({ success: true, data: hero });
  } catch (error) {
    next(error);
  }
};

// @desc    Update hero content
// @route   PUT /api/hero
// @access  Private (Require manage_homepage permission)
exports.updateHeroContent = async (req, res, next) => {
  try {
    let hero = await HeroContent.findOne();
    if (!hero) {
      hero = await HeroContent.create({});
    }

    hero = await HeroContent.findByIdAndUpdate(hero._id, req.body, {
      new: true,
      runValidators: true
    });

    res.status(200).json({ success: true, data: hero });
  } catch (error) {
    next(error);
  }
};
