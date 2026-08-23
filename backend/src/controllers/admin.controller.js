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

// @desc    Create an admin
// @route   POST /api/admins
// @access  Private (Require manage_admins permission)
exports.createAdmin = async (req, res, next) => {
  try {
    const { firebaseUid, name, email, role, permissions, status } = req.body;
    
    if (!firebaseUid || !name || !email) {
      return res.status(400).json({ success: false, message: 'Please provide firebaseUid, name, and email' });
    }

    const admin = await User.create({
      firebaseUid,
      name,
      email,
      role: role || 'viewer',
      permissions: permissions || [],
      status: status || 'active'
    });

    res.status(201).json({ success: true, data: admin });
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

// @desc    Delete an admin
// @route   DELETE /api/admins/:id
// @access  Private (Require manage_admins permission)
exports.deleteAdmin = async (req, res, next) => {
  try {
    const admin = await User.findById(req.params.id);
    if (!admin) {
      return res.status(404).json({ success: false, message: 'Admin not found' });
    }

    await admin.deleteOne();
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    next(error);
  }
};
