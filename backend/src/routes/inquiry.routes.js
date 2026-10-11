const express = require('express');
const {
  createInquiry,
  getMyInquiries,
  getInquiries,
  updateInquiry,
  deleteInquiry,
  replyToInquiry
} = require('../controllers/inquiry.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

const router = express.Router();

// Customer route: Get own enquiries
router.get('/my', protect, getMyInquiries);

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
