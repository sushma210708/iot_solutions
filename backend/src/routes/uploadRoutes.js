const express = require('express');
const multer = require('multer');
const { uploadImageToCloud, uploadMultipleImagesToCloud } = require('../controllers/uploadController');

const router = express.Router();

// Configure multer to store files in memory as Buffers
const storage = multer.memoryStorage();
const upload = multer({ storage });

// Expecting form-data with a key named "image"
router.post('/image', upload.single('image'), uploadImageToCloud);

// Expecting form-data with a key named "images" for multiple files
router.post('/images', upload.array('images', 10), uploadMultipleImagesToCloud);

module.exports = router;
