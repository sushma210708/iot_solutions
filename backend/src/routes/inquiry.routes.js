const express = require('express');
const {
  createInquiry,
  getMyInquiries,
  getInquiries,
  updateInquiry,
  deleteInquiry,
  replyToInquiry,
  getNotificationSettings,
  updateNotificationSettings,
  sendTestNotification
} = require('../controllers/inquiry.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

// Customer route: Get own enquiries
router.get('/my', protect, getMyInquiries);

// Notification settings routes (placed before /:id)
router.get('/settings/notifications', protect, authorize('super_admin', 'content_admin', 'viewer'), getNotificationSettings);
router.put('/settings/notifications', protect, authorize('super_admin', 'content_admin'), updateNotificationSettings);
router.post('/settings/notifications/test', protect, authorize('super_admin', 'content_admin'), sendTestNotification);

// Base route: Public creation, Admin retrieval
router.route('/')
  .post(createInquiry) // Public or customer submission
  .get(protect, authorize('super_admin', 'content_admin', 'viewer'), getInquiries); // Admin route to read all

// Admin reply route: Email reply to customer & store in responses
router.post('/:id/reply', protect, authorize('super_admin', 'content_admin'), replyToInquiry);

// Admin routes: Update status/notes, Delete
router.route('/:id')
  .put(protect, authorize('super_admin', 'content_admin'), updateInquiry)
  .delete(protect, authorize('super_admin', 'content_admin'), deleteInquiry);

module.exports = router;
