const User = require('../models/user.model');

exports.getMe = async (req, res) => {
  try {
    // req.user is already populated by the protect middleware
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'User not found' });
    }

    res.json({
      success: true,
      user: {
        id: req.user._id,
        firebaseUid: req.user.firebaseUid,
        name: req.user.name,
        email: req.user.email,
        role: req.user.role,
        permissions: req.user.permissions,
        status: req.user.status,
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.syncUser = async (req, res) => {
  try {
    const { uid, email, name } = req.firebaseUser;
    
    // Check if user exists by email
    let user = await User.findOne({ email: email });
    
    if (user) {
      // If user exists but firebaseUid is different (e.g. they were added by email)
      if (user.firebaseUid !== uid) {
        user.firebaseUid = uid;
        await user.save();
      }
    } else {
      // If user doesn't exist, create them as a normal user!
      user = await User.create({
        name: name || email.split('@')[0],
        email: email,
        firebaseUid: uid,
        role: 'user', // Default role for Registered Users
        status: 'active'
      });
    }
    
    res.status(200).json({ success: true, user });
  } catch (error) {
    console.error('syncUser error:', error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.updateProfile = async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }

    const { name, emailUpdates } = req.body;
    const updateFields = {};

    if (name !== undefined && typeof name === 'string' && name.trim()) {
      updateFields.name = name.trim();
    }
    if (emailUpdates !== undefined) {
      updateFields.emailUpdates = Boolean(emailUpdates);
    }

    // Strictly ignore any role, status, permissions, email, or firebaseUid tampering
    const updatedUser = await User.findByIdAndUpdate(
      req.user._id,
      { $set: updateFields },
      { new: true, runValidators: true }
    );

    res.status(200).json({
      success: true,
      user: {
        id: updatedUser._id,
        firebaseUid: updatedUser.firebaseUid,
        name: updatedUser.name,
        email: updatedUser.email,
        role: updatedUser.role,
        permissions: updatedUser.permissions,
        status: updatedUser.status,
        emailUpdates: updatedUser.emailUpdates
      }
    });
  } catch (error) {
    console.error('updateProfile error:', error);
    res.status(500).json({ success: false, message: 'Failed to update profile' });
  }
};
