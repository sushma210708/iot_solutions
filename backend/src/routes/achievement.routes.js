const express = require('express');
const {
  createAchievement,
  getAchievements,
  updateAchievement,
  deleteAchievement,
} = require('../controllers/achievement.controller');

const router = express.Router();

router.route('/').get(getAchievements).post(createAchievement);
router.route('/:id').put(updateAchievement).delete(deleteAchievement);

module.exports = router;
