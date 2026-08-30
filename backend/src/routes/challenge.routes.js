const express = require('express');
const {
  getAllChallenges,
  getChallengeById,
  createChallenge,
  updateChallenge,
  deleteChallenge
} = require('../controllers/challenge.controller');
const { protect, requirePermission } = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/', getAllChallenges);
router.get('/:id', getChallengeById);

// Protected routes (require manage_homepage permission)
router.use(protect);
router.post('/', requirePermission('manage_homepage'), createChallenge);
router.put('/:id', requirePermission('manage_homepage'), updateChallenge);
router.delete('/:id', requirePermission('manage_homepage'), deleteChallenge);

module.exports = router;
