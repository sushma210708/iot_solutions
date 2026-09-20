const express = require('express');
const { getAbout, updateAbout } = require('../controllers/about.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

router.route('/')
  .get(getAbout)
  .put(protect, authorize('admin', 'super_admin'), updateAbout);

module.exports = router;
