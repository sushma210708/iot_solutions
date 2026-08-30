const express = require('express');
const {
  getAllTestimonials,
  getTestimonialById,
  createTestimonial,
  updateTestimonial,
  deleteTestimonial
} = require('../controllers/testimonial.controller');
const { protect, requirePermission } = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/', getAllTestimonials);
router.get('/:id', getTestimonialById);

// Protected routes (require manage_homepage permission)
router.use(protect);
router.post('/', requirePermission('manage_homepage'), createTestimonial);
router.put('/:id', requirePermission('manage_homepage'), updateTestimonial);
router.delete('/:id', requirePermission('manage_homepage'), deleteTestimonial);

module.exports = router;
