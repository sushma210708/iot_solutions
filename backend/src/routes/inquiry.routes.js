const express = require('express');
const {
  createInquiry,
  getInquiries,
  updateInquiry,
  deleteInquiry
} = require('../controllers/inquiry.controller');
const { protectFirebase, protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.route('/')
  .post(createInquiry) // Public route for submission
  .get(protectFirebase, protect, getInquiries); // Admin route to read

router.route('/:id')
  .put(protectFirebase, protect, updateInquiry)
  .delete(protectFirebase, protect, deleteInquiry);

module.exports = router;
