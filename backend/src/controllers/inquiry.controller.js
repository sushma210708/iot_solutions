const Inquiry = require('../models/inquiry.model');
const User = require('../models/user.model');
const emailService = require('../services/emailService');
const { getAuth } = require('firebase-admin/auth');

// Email regex
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// @desc    Create a new project inquiry (Public or Authenticated Customer)
// @route   POST /api/inquiries
// @access  Public / Customer
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

    // Determine ownership securely from verified token if provided (NEVER trust body fields)
    let authenticatedUid = null;
    let authenticatedUserId = null;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
      try {
        const token = req.headers.authorization.split(' ')[1];
        const decoded = await getAuth().verifyIdToken(token);
        if (decoded && decoded.uid) {
          authenticatedUid = decoded.uid;
          const userDoc = await User.findOne({ firebaseUid: decoded.uid });
          if (userDoc) {
            authenticatedUserId = userDoc._id;
          }
        }
      } catch (tokenErr) {
        // Fall back gracefully for public submissions
      }
    }

    // Create inquiry
    const inquiry = await Inquiry.create({
      name: name.trim(),
      email: trimmedEmail,
      phone: trimmedPhone,
      message: requirements,
      status: 'Received',
      firebaseUid: authenticatedUid,
      userId: authenticatedUserId
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

// @desc    Get enquiries submitted by the current authenticated customer
// @route   GET /api/inquiries/my
// @access  Private (Authenticated Customer)
exports.getMyInquiries = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }

    const userEmail = (req.user.email || '').toLowerCase().trim();

    const inquiries = await Inquiry.find({
      $or: [
        { firebaseUid: req.user.firebaseUid },
        { userId: req.user._id },
        { email: userEmail }
      ]
    }).sort({ createdAt: -1 });

    // Also fetch any email campaigns / direct messages sent to this customer
    const EmailCampaign = require('../models/emailCampaign.model');
    const campaigns = await EmailCampaign.find({
      'recipients.email': userEmail
    }).sort({ createdAt: 1 });

    const formattedInquiries = inquiries.map(inq => {
      const inqObj = inq.toObject();
      let responses = inqObj.responses || [];

      // Merge campaign messages sent to this customer
      for (const camp of campaigns) {
        const alreadyExists = responses.some(r => r.message === camp.message);
        if (!alreadyExists) {
          responses.push({
            message: camp.message,
            subject: camp.subject,
            senderName: camp.sentByName || 'Green Fusion Team',
            senderRole: 'admin',
            sentAt: camp.createdAt,
            emailSent: true,
            emailProvider: 'email_service',
            emailError: ''
          });
        }
      }

      responses.sort((a, b) => new Date(a.sentAt) - new Date(b.sentAt));
      inqObj.responses = responses;

      if (responses.length > 0 && (inqObj.status === 'Received' || inqObj.status === 'New')) {
        inqObj.status = 'Contacted';
      }

      return inqObj;
    });

    res.status(200).json({
      success: true,
      count: formattedInquiries.length,
      inquiries: formattedInquiries
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
    if (!req.user || !['super_admin', 'content_admin', 'viewer'].includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Access denied: Administrator privileges required' });
    }

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
// @access  Private (Super/Content Admin only)
exports.updateInquiry = async (req, res, next) => {
  try {
    if (!req.user || !['super_admin', 'content_admin'].includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Access denied: Administrator privileges required' });
    }

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
// @access  Private (Super/Content Admin only)
exports.deleteInquiry = async (req, res, next) => {
  try {
    if (!req.user || !['super_admin', 'content_admin'].includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Access denied: Administrator privileges required' });
    }

    const inquiry = await Inquiry.findByIdAndDelete(req.params.id);

    if (!inquiry) {
      return res.status(404).json({ success: false, message: 'Inquiry not found' });
    }

    res.status(200).json({ success: true, message: 'Inquiry deleted successfully' });
  } catch (error) {
    next(error);
  }
};

// @desc    Send email reply to customer and record message in inquiry responses
// @route   POST /api/inquiries/:id/reply
// @access  Private (Super/Content Admin only)
exports.replyToInquiry = async (req, res, next) => {
  try {
    if (!req.user || !['super_admin', 'content_admin'].includes(req.user.role)) {
      return res.status(403).json({ success: false, message: 'Access denied: Administrator privileges required' });
    }

    const { message, subject, newStatus } = req.body;

    if (!message || !message.trim()) {
      return res.status(400).json({ success: false, message: 'Reply message cannot be empty' });
    }

    const inquiry = await Inquiry.findById(req.params.id);
    if (!inquiry) {
      return res.status(404).json({ success: false, message: 'Inquiry not found' });
    }

    const senderName = req.user.name || 'Green Fusion Team';
    const emailSubject = subject && subject.trim() ? subject.trim() : `Regarding your Project Inquiry (${inquiry.inquiryId}) — Green Fusion IoT Solutions`;

    // Send email to customer
    let emailSuccess = false;
    let emailProvider = '';
    let emailError = '';

    try {
      const sendResult = await emailService.sendCustomerInquiryReply({
        to: inquiry.email,
        customerName: inquiry.name,
        inquiryId: inquiry.inquiryId,
        message: message.trim(),
        subject: emailSubject,
        adminName: senderName
      });
      emailSuccess = sendResult.success;
      emailProvider = sendResult.provider || '';
      emailError = sendResult.error || '';
    } catch (err) {
      emailSuccess = false;
      emailError = err.message || 'Email delivery failed';
    }

    // Add response to inquiry
    const responseItem = {
      message: message.trim(),
      subject: emailSubject,
      senderName,
      senderRole: req.user.role,
      sentAt: new Date(),
      emailSent: emailSuccess,
      emailProvider,
      emailError
    };

    if (!inquiry.responses) {
      inquiry.responses = [];
    }
    inquiry.responses.push(responseItem);

    // Update status if provided or update from Received/New to Contacted
    if (newStatus && typeof newStatus === 'string' && newStatus.trim()) {
      inquiry.status = newStatus.trim();
    } else if (inquiry.status === 'Received' || inquiry.status === 'New') {
      inquiry.status = 'Contacted';
    }

    await inquiry.save();

    res.status(200).json({
      success: true,
      message: emailSuccess ? 'Reply emailed to customer and saved to inquiry' : 'Reply saved to inquiry (Email notification encountered an issue)',
      emailSent: emailSuccess,
      response: responseItem,
      inquiry
    });
  } catch (error) {
    next(error);
  }
};
