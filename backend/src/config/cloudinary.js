const cloudinary = require('cloudinary').v2;

const connectCloudinary = () => {
  if (!process.env.CLOUDINARY_CLOUD_NAME) {
    console.warn('Cloudinary environment variables not set. Skipping Cloudinary connection.');
    return;
  }

  cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
  });
  console.log('Cloudinary Configured');
};

module.exports = { cloudinary, connectCloudinary };
