const Inquiry = require('../models/inquiry.model');
const emailService = require('../services/emailService');

// Email regex
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// @desc    Create a new project inquiry (Public)
// @route   POST /api/inquiries
// @access  Public
exports.createInquiry = async (req, res, next) => {
  try {
    const { name, email, phone, message, projectRequirements } = req.body;
    const requirements = (message || projectRequirements || '').trim();

    // Field validations
    if (!name || !name.trim()) {
      return res.status(400).json({ success: false, message: 'Full name is required' });
    }
    if (!email || !EMAIL_REGEX.test(email.trim())) {
      return res.status(400).json({ success: false, message: 'Please provide a valid email address' });
    }
    if (!phone || phone.trim().length < 6) {
      return res.status(400).json({ success: false, message: 'Please provide a valid phone number' });
    }
    if (!requirements || requirements.length < 5) {
      return res.status(400).json({ success: false, message: 'Please provide your project requirements' });
    }

    const trimmedEmail = email.trim().toLowerCase();
    const trimmedPhone = phone.trim();

    // Prevent duplicate rapid submissions (within 30 seconds)
    const thirtySecondsAgo = new Date(Date.now() - 30 * 1000);
    const existingRecent = await Inquiry.findOne({
      email: trimmedEmail,
      phone: trimmedPhone,
      createdAt: { $gte: thirtySecondsAgo }
    });

    if (existingRecent) {
      return res.status(200).json({
        success: true,
        inquiry: existingRecent,
        message: 'Your project inquiry has already been received.'
      });
    }

    // Create inquiry
    const inquiry = await Inquiry.create({
      name: name.trim(),
      email: trimmedEmail,
      phone: trimmedPhone,
      message: requirements,
      status: 'New'
    });

    // Send email notification to admin asynchronously with delivery status capture
    try {
      const emailResult = await emailService.sendAdminInquiryNotification(inquiry);
      inquiry.emailNotification = {
        sent: emailResult.success,
        provider: emailResult.provider || 'unknown',
        recipient: emailService.adminEmail,
        sentAt: new Date(),
        error: emailResult.error || ''
      };
      await inquiry.save();
    } catch (emailErr) {
      console.error('[InquiryController] Email notification error:', emailErr.message);
      inquiry.emailNotification = {
        sent: false,
        recipient: emailService.adminEmail,
        error: emailErr.message
      };
      await inquiry.save();
      // Notice: We don't fail the user's inquiry response even if email delivery encounters an error
    }

    res.status(201).json({
      success: true,
      inquiry,
      message: 'Inquiry received successfully'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get all inquiries with search & filter
// @route   GET /api/inquiries
// @access  Private (Admins only)
exports.getInquiries = async (req, res, next) => {
  try {
    const { search, status, sort } = req.query;
    const query = {};

    // Filter by status if provided
    if (status && status !== 'All') {
      if (status === 'Contacted') {
        query.status = { $in: ['Contacted', 'Reviewed'] };
      } else if (status === 'Closed') {
        query.status = { $in: ['Closed', 'Resolved'] };
      } else {
        query.status = status;
      }
    }

    // Search by name, email, phone, or inquiryId
    if (search && search.trim()) {
      const regex = new RegExp(search.trim(), 'i');
      query.$or = [
        { name: regex },
        { email: regex },
        { phone: regex },
        { inquiryId: regex },
        { message: regex }
      ];
    }

    const sortOrder = sort === 'oldest' ? { createdAt: 1 } : { createdAt: -1 };
    const inquiries = await Inquiry.find(query).sort(sortOrder);

    res.status(200).json({ 
      success: true, 
      count: inquiries.length, 
      inquiries 
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update inquiry status or internal notes
// @route   PUT /api/inquiries/:id
// @access  Private
exports.updateInquiry = async (req, res, next) => {
  try {
    const { status, internalNotes } = req.body;
    const updateFields = {};

    if (status !== undefined) updateFields.status = status;
    if (internalNotes !== undefined) updateFields.internalNotes = internalNotes;

    const inquiry = await Inquiry.findByIdAndUpdate(
      req.params.id, 
      { $set: updateFields }, 
      { new: true, runValidators: true }
    );

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

    res.status(200).json({ success: true, message: 'Inquiry deleted successfully' });
  } catch (error) {
    next(error);
  }
};
