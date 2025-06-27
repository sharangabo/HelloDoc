const { auth } = require('../config/firebase');

/**
 * Middleware to authenticate JWT tokens from Firebase
 */
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        error: 'Access token required',
        message: 'No authorization token provided'
      });
    }

    try {
      // Verify the Firebase ID token
      const decodedToken = await auth.verifyIdToken(token);
      
      // Add user info to request object
      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        phoneNumber: decodedToken.phone_number,
        emailVerified: decodedToken.email_verified,
        providerData: decodedToken.provider_data
      };

      next();
    } catch (firebaseError) {
      console.error('Firebase token verification failed:', firebaseError);
      return res.status(403).json({
        error: 'Invalid token',
        message: 'The provided token is invalid or expired'
      });
    }
  } catch (error) {
    console.error('Authentication middleware error:', error);
    return res.status(500).json({
      error: 'Authentication error',
      message: 'An error occurred during authentication'
    });
  }
};

/**
 * Optional authentication middleware - doesn't fail if no token provided
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      try {
        const decodedToken = await auth.verifyIdToken(token);
        req.user = {
          uid: decodedToken.uid,
          email: decodedToken.email,
          phoneNumber: decodedToken.phone_number,
          emailVerified: decodedToken.email_verified,
          providerData: decodedToken.provider_data
        };
      } catch (firebaseError) {
        // Token is invalid, but we don't fail the request
        console.warn('Invalid token in optional auth:', firebaseError.message);
      }
    }

    next();
  } catch (error) {
    console.error('Optional auth middleware error:', error);
    next();
  }
};

/**
 * Middleware to check if user has specific role
 */
const requireRole = (role) => {
  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          error: 'Authentication required',
          message: 'User must be authenticated to access this resource'
        });
      }

      // Get user document from Firestore to check role
      const { collections } = require('../config/firebase');
      const userDoc = await collections.users.doc(req.user.uid).get();

      if (!userDoc.exists) {
        return res.status(404).json({
          error: 'User not found',
          message: 'User profile not found in database'
        });
      }

      const userData = userDoc.data();
      
      if (userData.role !== role) {
        return res.status(403).json({
          error: 'Insufficient permissions',
          message: `This endpoint requires ${role} role`
        });
      }

      next();
    } catch (error) {
      console.error('Role check middleware error:', error);
      return res.status(500).json({
        error: 'Authorization error',
        message: 'An error occurred during authorization'
      });
    }
  };
};

module.exports = {
  authenticateToken,
  optionalAuth,
  requireRole
}; 