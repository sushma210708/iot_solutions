const express = require('express');
const { getMe, syncUser, updateProfile } = require('../controllers/auth.controller');
const { protect, protectFirebase } = require('../middleware/auth.middleware');

const router = express.Router();

router.post('/sync', protectFirebase, syncUser);
router.get('/me', protect, getMe);
router.put('/profile', protect, updateProfile);

module.exports = router;
