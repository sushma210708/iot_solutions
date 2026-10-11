const User = require('../models/user.model');

// @desc    Get all admins
// @route   GET /api/admins
// @access  Private (Require manage_admins permission)
exports.getAdmins = async (req, res, next) => {
  try {
    const admins = await User.find({ role: { $in: ['super_admin', 'content_admin', 'viewer'] } }).sort({ createdAt: -1 });
    res.status(200).json({ success: true, count: admins.length, data: admins });
  } catch (error) {
    next(error);
  }
};

// @desc    Create / Grant an admin or viewer role
// @route   POST /api/admins
// @access  Private (Require manage_admins or super_admin / content_admin)
exports.createAdmin = async (req, res, next) => {
  try {
    const { firebaseUid, name, email, role, permissions, status } = req.body;
    
    if (!email || !email.trim()) {
      return res.status(400).json({ success: false, message: 'Please provide an email address' });
    }

    const trimmedEmail = email.trim().toLowerCase();
    const assignedRole = role || 'viewer';
    const assignedName = (name && name.trim()) ? name.trim() : trimmedEmail.split('@')[0];

    // Check if user already exists
    let existingUser = await User.findOne({ email: trimmedEmail });
    if (existingUser) {
      existingUser.role = assignedRole;
      if (name && name.trim()) existingUser.name = assignedName;
      if (permissions && Array.isArray(permissions)) existingUser.permissions = permissions;
      if (status) existingUser.status = status;
      await existingUser.save();
      return res.status(200).json({
        success: true,
        message: `Admin/Portal access updated for ${trimmedEmail} (${assignedRole})`,
        data: existingUser
      });
    }

    // Pre-authorize new team email with unique pending UID
    const pendingUid = firebaseUid || ('pending_' + Buffer.from(trimmedEmail).toString('hex'));
    const admin = await User.create({
      firebaseUid: pendingUid,
      name: assignedName,
      email: trimmedEmail,
      role: assignedRole,
      permissions: permissions || [],
      status: status || 'active'
    });

    res.status(201).json({
      success: true,
      message: `Access granted for ${trimmedEmail} (${assignedRole}). They can now log in using this email.`,
      data: admin
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update an admin
// @route   PUT /api/admins/:id
// @access  Private (Require manage_admins permission)
exports.updateAdmin = async (req, res, next) => {
  try {
    let admin = await User.findById(req.params.id);
    if (!admin) {
      return res.status(404).json({ success: false, message: 'Admin not found' });
    }

    // Prevent changing super_admin role if not authorized or protect against self lock-out
    if (admin.role === 'super_admin' && req.body.role && req.body.role !== 'super_admin') {
      // In a real app, ensure at least one super admin remains
    }

    admin = await User.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    res.status(200).json({ success: true, data: admin });
  } catch (error) {
    next(error);
  }
};

// @desc    Revoke admin access / Delete admin
// @route   DELETE /api/admins/:id
// @access  Private (Require manage_admins permission)
exports.deleteAdmin = async (req, res, next) => {
  try {
    const admin = await User.findById(req.params.id);
    if (!admin) {
      return res.status(404).json({ success: false, message: 'Admin not found' });
    }

    if (admin.email.toLowerCase() === 'gfiotsolutions@gmail.com') {
      return res.status(400).json({ success: false, message: 'Cannot remove primary super admin account.' });
    }

    if (admin.firebaseUid && admin.firebaseUid.startsWith('pending_')) {
      await admin.deleteOne();
    } else {
      admin.role = 'user';
      await admin.save();
    }

    res.status(200).json({ success: true, message: `Admin access revoked for ${admin.email}` });
  } catch (error) {
    next(error);
  }
};
