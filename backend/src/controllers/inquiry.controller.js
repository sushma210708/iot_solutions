const Inquiry = require('../models/inquiry.model');

// @desc    Create a new inquiry (Public)
// @route   POST /api/inquiries
// @access  Public
exports.createInquiry = async (req, res, next) => {
  try {
    const { name, email, phone, message } = req.body;

    if (!name || !email || !phone || !message) {
      return res.status(400).json({ success: false, message: 'Please provide name, email, phone, and message' });
    }

    const inquiry = await Inquiry.create({
      name,
      email,
      phone,
      message,
    });

    res.status(201).json({ success: true, inquiry });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all inquiries
// @route   GET /api/inquiries
// @access  Private (Admins only)
exports.getInquiries = async (req, res, next) => {
  try {
    const inquiries = await Inquiry.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, inquiries });
  } catch (error) {
    next(error);
  }
};

// @desc    Update inquiry status
// @route   PUT /api/inquiries/:id
// @access  Private
exports.updateInquiry = async (req, res, next) => {
  try {
    const inquiry = await Inquiry.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });

    if (!inquiry) {
      return res.status(404).json({ success: false, message: 'Inquiry not found' });
    }

    res.status(200).json({ success: true, inquiry });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete an inquiry
// @route   DELETE /api/inquiries/:id
// @access  Private
exports.deleteInquiry = async (req, res, next) => {
  try {
    const inquiry = await Inquiry.findByIdAndDelete(req.params.id);

    if (!inquiry) {
      return res.status(404).json({ success: false, message: 'Inquiry not found' });
    }

    res.status(200).json({ success: true, message: 'Inquiry deleted' });
  } catch (error) {
    next(error);
  }
};
