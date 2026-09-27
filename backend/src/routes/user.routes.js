const express = require('express');
const { getUsers, updateUser, deleteUser } = require('../controllers/user.controller');
const { protect, requirePermission } = require('../middleware/auth.middleware');

const router = express.Router();

router.use(protect);
// Optional: If you have specific permissions for managing users, use them here. 
// Otherwise, just protecting it allows any logged-in admin (depending on your logic). 
// Assuming all admins can view/manage users for now, or you can add a permission.

router.route('/')
  .get(getUsers);

router.route('/:id')
  .put(updateUser)
  .delete(deleteUser);

module.exports = router;
