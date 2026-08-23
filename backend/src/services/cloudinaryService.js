const { cloudinary } = require('../config/cloudinary');
const streamifier = require('streamifier');

const uploadImage = (buffer, folder = 'greenfusion') => {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder },
      (error, result) => {
        if (result) {
          resolve(result);
        } else {
          reject(error);
        }
      }
    );
    
    streamifier.createReadStream(buffer).pipe(uploadStream);
  });
};

module.exports = { uploadImage };
