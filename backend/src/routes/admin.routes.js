const express = require('express');
const { getAdmins, createAdmin, updateAdmin, deleteAdmin } = require('../controllers/admin.controller');
const { protect, requirePermission } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect);
router.use(requirePermission('manage_admins')); // Only super_admin or users with manage_admins permission

router.route('/')
  .get(getAdmins)
  .post(createAdmin);

router.route('/:id')
  .put(updateAdmin)
  .delete(deleteAdmin);

module.exports = router;
