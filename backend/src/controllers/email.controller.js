const EmailCampaign = require('../models/emailCampaign.model');
const User = require('../models/user.model');
const emailService = require('../services/emailService');

// @desc    Get eligible registered users for email recipient selection
// @route   GET /api/emails/recipients
// @access  Private (Admins only)
exports.getEligibleRecipients = async (req, res, next) => {
  try {
    const users = await User.find({ status: 'active' }).select('name email role status emailUpdates createdAt');
    res.status(200).json({ success: true, count: users.length, users });
  } catch (error) {
    next(error);
  }
};

// @desc    Send email campaign to registered users
// @route   POST /api/emails/send
// @access  Private (Admins only)
exports.sendCampaign = async (req, res, next) => {
  try {
    const { subject, message, recipientType, selectedUserIds, emailType } = req.body;

    if (!subject || !subject.trim()) {
      return res.status(400).json({ success: false, message: 'Email subject is required' });
    }
    if (!message || !message.trim()) {
      return res.status(400).json({ success: false, message: 'Email message is required' });
    }

    // Determine target recipients from MongoDB
    let targetUsers = [];

    if (recipientType === 'all') {
      targetUsers = await User.find({ status: 'active' }).select('name email');
    } else if (recipientType === 'selected' || recipientType === 'single') {
      if (!selectedUserIds || !Array.isArray(selectedUserIds) || selectedUserIds.length === 0) {
        return res.status(400).json({ success: false, message: 'Please select at least one recipient' });
      }
      targetUsers = await User.find({ 
        _id: { $in: selectedUserIds },
        status: 'active' 
      }).select('name email');
    } else {
      return res.status(400).json({ success: false, message: 'Invalid recipient type' });
    }

    if (targetUsers.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'No active eligible recipients found for the selected criteria' 
      });
    }

    const recipientList = targetUsers.map(u => ({
      email: u.email,
      name: u.name || 'User'
    }));

    // Generate campaign document
    const campaign = new EmailCampaign({
      subject: subject.trim(),
      message: message.trim(),
      emailType: emailType || 'announcement',
      recipientType: recipientType || 'all',
      recipientCount: recipientList.length,
      sentBy: req.user ? req.user._id : null,
      sentByName: req.user ? req.user.name : 'Administrator',
      status: 'sending'
    });

    // Send emails via emailService
    const sendResults = await emailService.sendCampaignEmail({
      recipients: recipientList,
      subject: subject.trim(),
      message: message.trim(),
      campaignId: campaign.campaignId
    });

    campaign.recipients = sendResults.results;
    campaign.stats = {
      total: sendResults.total,
      successful: sendResults.successful,
      failed: sendResults.failed
    };

    if (sendResults.failed === 0) {
      campaign.status = 'sent';
    } else if (sendResults.successful > 0) {
      campaign.status = 'partial_failure';
    } else {
      campaign.status = 'failed';
    }

    await campaign.save();

    // Also record responses on any inquiries for these recipients
    try {
      const Inquiry = require('../models/inquiry.model');
      for (const rec of recipientList) {
        await Inquiry.updateMany(
          { email: rec.email.toLowerCase() },
          {
            $push: {
              responses: {
                message: message.trim(),
                subject: subject.trim(),
                senderName: req.user ? req.user.name : 'Green Fusion Team',
                senderRole: 'admin',
                sentAt: new Date(),
                emailSent: true,
                emailProvider: 'email_campaign',
                emailError: ''
              }
            },
            $set: { status: 'Contacted' }
          }
        );
      }
    } catch (inqErr) {
      console.warn('Could not sync campaign to inquiries:', inqErr.message);
    }

    res.status(200).json({
      success: true,
      message: `Emails processed: ${sendResults.successful} delivered, ${sendResults.failed} failed.`,
      campaign
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get past email campaigns history
// @route   GET /api/emails/campaigns
// @access  Private (Admins only)
exports.getCampaigns = async (req, res, next) => {
  try {
    const campaigns = await EmailCampaign.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: campaigns.length, campaigns });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single campaign detail
// @route   GET /api/emails/campaigns/:id
// @access  Private (Admins only)
exports.getCampaignById = async (req, res, next) => {
  try {
    const campaign = await EmailCampaign.findById(req.params.id);
    if (!campaign) {
      return res.status(404).json({ success: false, message: 'Campaign not found' });
    }
    res.status(200).json({ success: true, campaign });
  } catch (error) {
    next(error);
  }
};
