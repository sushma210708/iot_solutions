const express = require('express');
const router = express.Router();
const {
  createProject,
  getProjects,
  getFeaturedProject,
  updateProject,
  deleteProject
} = require('../controllers/project.controller');
const { protect, authorize } = require('../middleware/auth.middleware');

router.route('/')
  .post(protect, authorize('super_admin', 'content_admin'), createProject)
  .get(getProjects);

router.route('/featured').get(getFeaturedProject);

router.route('/:id')
  .put(protect, authorize('super_admin', 'content_admin'), updateProject)
  .delete(protect, authorize('super_admin', 'content_admin'), deleteProject);

module.exports = router;
