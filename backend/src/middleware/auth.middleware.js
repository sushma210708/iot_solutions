const { getApps, initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const User = require('../models/user.model');

// Ensure firebase admin is initialized once
if (!getApps().length) {
  try {
    let firebaseConfig = { projectId: process.env.FIREBASE_PROJECT_ID || 'company-web-3f023' };
    
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
      // Parse the JSON string from Render environment variable
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      firebaseConfig.credential = cert(serviceAccount);
    }
    
    initializeApp(firebaseConfig);
  } catch (error) {
    console.error('Firebase admin initialization error', error);
  }
}

exports.protect = async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }
  
  if (!token) {
    return res.status(401).json({ success: false, message: 'Not authorized to access this route' });
  }

  try {
    const decodedToken = await getAuth().verifyIdToken(token);
    
    // Find user in MongoDB
    const user = await User.findOne({ firebaseUid: decodedToken.uid });
    
    if (!user) {
      return res.status(401).json({ success: false, message: 'User not found in database' });
    }
    
    if (user.status !== 'active') {
      return res.status(403).json({ success: false, message: 'Your account is disabled' });
    }

    req.user = user;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(401).json({ success: false, message: 'Not authorized, token failed' });
  }
};

exports.protectFirebase = async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }
  
  if (!token) {
    return res.status(401).json({ success: false, message: 'Not authorized to access this route' });
  }

  try {
    const decodedToken = await getAuth().verifyIdToken(token);
    req.firebaseUser = decodedToken;
    next();
  } catch (error) {
    console.error('Firebase Auth middleware error:', error);
    return res.status(401).json({ success: false, message: 'Not authorized, token failed' });
  }
};

exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({ 
        success: false, 
        message: `User role ${req.user ? req.user.role : 'Unknown'} is not authorized to access this route`
      });
    }
    next();
  };
};

exports.requirePermission = (permission) => {
  return (req, res, next) => {
    if (req.user && req.user.role === 'super_admin') {
      return next(); // Super admin has all permissions
    }
    
    if (!req.user || !req.user.permissions || !req.user.permissions.includes(permission)) {
      return res.status(403).json({
        success: false,
        message: `You do not have the required permission: ${permission}`
      });
    }
    next();
  };
};
