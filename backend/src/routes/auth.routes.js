const express = require('express');
const { getMe } = require('../controllers/auth.controller');
const { protect } = require('../middleware/auth.middleware');

const router = express.Router();

router.get('/me', protect, getMe);

module.exports = router;
