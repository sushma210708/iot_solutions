const express = require('express');
const { getHeroContent, updateHeroContent } = require('../controllers/hero.controller');
const { protect, requirePermission } = require('../middleware/auth.middleware');

const router = express.Router();

router.route('/')
  .get(getHeroContent)
  .put(protect, requirePermission('manage_homepage'), updateHeroContent);

module.exports = router;
