const express = require('express');
const {
  createInquiry,
  getInquiries,
  updateInquiry,
  deleteInquiry
} = require('../controllers/inquiry.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.route('/')
  .post(createInquiry) // Public route for submission
  .get(protect, getInquiries); // Admin route to read

router.route('/:id')
  .put(protect, updateInquiry)
  .delete(protect, deleteInquiry);

module.exports = router;
