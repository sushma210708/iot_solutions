const express = require('express');
const { getAdmins, createAdmin, updateAdmin, deleteAdmin } = require('../controllers/admin.controller');
const { protect, requirePermission } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect);
router.use((req, res, next) => {
  if (req.user && (req.user.role === 'super_admin' || req.user.role === 'content_admin' || (req.user.permissions && req.user.permissions.includes('manage_admins')))) {
    return next();
  }
  return res.status(403).json({ success: false, message: 'You do not have permission to manage team admin access' });
});

router.route('/')
  .get(getAdmins)
  .post(createAdmin);

router.route('/:id')
  .put(updateAdmin)
  .delete(deleteAdmin);

module.exports = router;
