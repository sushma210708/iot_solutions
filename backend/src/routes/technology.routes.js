const express = require('express');
const router = express.Router();
const techController = require('../controllers/technology.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.get('/', techController.getTechnology);
router.put('/', protect, authorize('admin', 'super_admin'), techController.updateTechnology);

module.exports = router;
