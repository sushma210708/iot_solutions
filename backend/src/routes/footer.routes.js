const express = require('express');
const { getFooter, updateFooter } = require('../controllers/footer.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.route('/')
  .get(getFooter)
  .put(protect, (req, res, next) => {
    if (
      req.user &&
      (req.user.role === 'super_admin' ||
       req.user.role === 'content_admin' ||
       (req.user.permissions && req.user.permissions.includes('manage_homepage')))
    ) {
      return next();
    }
    return res.status(403).json({ 
      success: false, 
      message: 'Not authorized to modify footer settings' 
    });
  }, updateFooter);

module.exports = router;
