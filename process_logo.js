const Jimp = require('jimp');

async function removeBlackBackground(inputPath, outputPath) {
  try {
    const image = await Jimp.read(inputPath);
    
    image.scan(0, 0, image.bitmap.width, image.bitmap.height, function(x, y, idx) {
      const red   = this.bitmap.data[idx + 0];
      const green = this.bitmap.data[idx + 1];
      const blue  = this.bitmap.data[idx + 2];
      
      if (red < 30 && green < 30 && blue < 30) {
        this.bitmap.data[idx + 3] = 0; 
      }
    });

    await image.writeAsync(outputPath);
    console.log('Background removed successfully!');
  } catch (err) {
    console.error('Error:', err);
  }
}

removeBlackBackground('C:/Users/Asus/.gemini/antigravity/brain/481a5976-97b0-4e64-9172-49e4c40f69cf/.user_uploaded/media_1791032012882.png', 'assets/logo.png');
