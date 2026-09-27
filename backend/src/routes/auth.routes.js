const express = require('express');
const { getMe, syncUser } = require('../controllers/auth.controller');
const { protect, protectFirebase } = require('../middleware/auth.middleware');

const router = express.Router();

router.post('/sync', protectFirebase, syncUser);
router.get('/me', protect, getMe);

module.exports = router;
