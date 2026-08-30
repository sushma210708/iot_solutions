const express = require('express');
const router = express.Router();
const {
  createUpdate,
  getUpdates,
  getAllUpdatesAdmin,
  updateUpdate,
  deleteUpdate
} = require('../controllers/update.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.route('/')
  .post(protect, authorize('super_admin', 'content_admin'), createUpdate)
  .get(getUpdates);

router.route('/admin')
  .get(protect, authorize('super_admin', 'content_admin'), getAllUpdatesAdmin);

router.route('/:id')
  .put(protect, authorize('super_admin', 'content_admin'), updateUpdate)
  .delete(protect, authorize('super_admin', 'content_admin'), deleteUpdate);

module.exports = router;
