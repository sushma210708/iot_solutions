exports.checkHealth = (req, res, next) => {
  try {
    res.status(200).json({
      success: true,
      message: 'Green Fusion API is running'
    });
  } catch (error) {
    next(error);
  }
};
