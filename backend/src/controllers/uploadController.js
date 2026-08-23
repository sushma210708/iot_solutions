const { uploadImage } = require('../services/cloudinaryService');

exports.uploadImageToCloud = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please upload an image file' });
    }

    // MIME type validation
    if (!req.file.mimetype.startsWith('image/')) {
      return res.status(400).json({ success: false, message: 'File must be an image (JPEG, PNG, etc.)' });
    }

    // File size validation (5MB limit)
    const MAX_SIZE = 5 * 1024 * 1024;
    if (req.file.size > MAX_SIZE) {
      return res.status(400).json({ success: false, message: 'Image size should be less than 5MB' });
    }

    // Upload to Cloudinary directly from memory buffer
    const result = await uploadImage(req.file.buffer);

    res.status(200).json({
      success: true,
      imageUrl: result.secure_url,
      publicId: result.public_id
    });
  } catch (error) {
    // Cloudinary errors or server errors will be caught here
    next(error);
  }
};

exports.uploadMultipleImagesToCloud = async (req, res, next) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, message: 'Please upload image files' });
    }

    const uploadPromises = req.files.map(async (file) => {
      if (!file.mimetype.startsWith('image/')) {
        throw new Error('All files must be images');
      }
      if (file.size > 5 * 1024 * 1024) {
        throw new Error('Image sizes should be less than 5MB');
      }
      const result = await uploadImage(file.buffer);
      return {
        url: result.secure_url,
        publicId: result.public_id
      };
    });

    const results = await Promise.all(uploadPromises);

    res.status(200).json({
      success: true,
      images: results
    });
  } catch (error) {
    next(error);
  }
};
