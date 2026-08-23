const express = require('express');
const { getFooter, updateFooter } = require('../controllers/footer.controller');
const { protect, requirePermission } = require('../middleware/auth.middleware');

const router = express.Router();

router.route('/')
  .get(getFooter)
  .put(protect, requirePermission('manage_homepage'), updateFooter); // Reusing manage_homepage permission for global website edits

module.exports = router;
