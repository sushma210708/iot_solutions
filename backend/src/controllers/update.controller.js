const Update = require('../models/update.model');
const User = require('../models/user.model');
const cloudinary = require('../config/cloudinary');
const axios = require('axios'); // for sending webhook to Apps Script

const APPS_SCRIPT_URL = process.env.APPS_SCRIPT_URL || '';

exports.createUpdate = async (req, res) => {
  try {
    const update = new Update(req.body);
    await update.save();
    res.status(201).json({ success: true, update });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.getUpdates = async (req, res) => {
  try {
    // Public route only gets Published
    const updates = await Update.find({ status: 'Published' }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, updates });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.getAllUpdatesAdmin = async (req, res) => {
  try {
    const updates = await Update.find().sort({ createdAt: -1 });
    res.status(200).json({ success: true, updates });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.updateUpdate = async (req, res) => {
  try {
    let update = await Update.findById(req.params.id);
    if (!update) return res.status(404).json({ success: false, error: 'Update not found' });

    Object.assign(update, req.body);

    // Trigger Notification if Published + Notify = true + Not Sent
    if (update.status === 'Published' && update.notifySubscribers && !update.notificationSent) {
      if (APPS_SCRIPT_URL) {
        try {
          const subscribers = await User.find({ emailUpdates: true }).select('email name');
          const emails = subscribers.map(u => u.email);

          if (emails.length > 0) {
            // Trigger background webhook
            axios.post(APPS_SCRIPT_URL, {
              title: update.title,
              description: update.shortDescription,
              emails: emails,
            }).catch(e => console.error('Apps Script Webhook Error:', e.message));
          }
          
          update.notificationSent = true; // Mark as sent so it doesn't send again
        } catch (err) {
          console.error('Error fetching subscribers:', err);
        }
      }
    }

    await update.save();
    res.status(200).json({ success: true, update });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.deleteUpdate = async (req, res) => {
  try {
    const update = await Update.findById(req.params.id);
    if (!update) return res.status(404).json({ success: false, error: 'Update not found' });

    if (update.cloudinaryPublicId) {
      await cloudinary.uploader.destroy(update.cloudinaryPublicId);
    }
    await update.deleteOne();
    res.status(200).json({ success: true, message: 'Update deleted' });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};
