const express = require('express');
const { getMentors, createMentor, updateMentor, deleteMentor } = require('../controllers/mentor.controller');
const { protect, requirePermission } = require('../middleware/auth.middleware');

const router = express.Router();

router.route('/')
  .get(getMentors) // Public route for website
  .post(protect, requirePermission('manage_mentors'), createMentor); // Protected

router.route('/:id')
  .put(protect, requirePermission('manage_mentors'), updateMentor) // Protected
  .delete(protect, requirePermission('manage_mentors'), deleteMentor); // Protected

module.exports = router;
