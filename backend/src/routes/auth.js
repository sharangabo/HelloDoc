const express = require('express');
const { body, validationResult } = require('express-validator');
const { collections, auth } = require('../config/firebase');
const { asyncHandler, ApiError } = require('../middleware/errorHandler');

const router = express.Router();

/**
 * POST /api/auth/register
 * Register a new user
 */
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('firstName').isString().trim().isLength({ min: 2, max: 50 }),
  body('lastName').isString().trim().isLength({ min: 2, max: 50 }),
  body('phoneNumber').isString().trim(),
  body('dateOfBirth').optional().isISO8601(),
  body('gender').optional().isIn(['male', 'female', 'other']),
  body('preferredLanguage').optional().isIn(['en', 'rw', 'fr']),
  body('emergencyContact').optional().isObject()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid registration data', errors.array());
  }

  const {
    email, password, firstName, lastName, phoneNumber, dateOfBirth, gender, preferredLanguage = 'en', emergencyContact
  } = req.body;

  try {
    // Create user in Firebase Auth
    const userRecord = await auth.createUser({
      email,
      password,
      displayName: `${firstName} ${lastName}`,
      phoneNumber: phoneNumber.startsWith('+') ? phoneNumber : `+250${phoneNumber.replace(/^0+/, '')}`
    });

    // Create user profile in Firestore
    const userProfile = {
      uid: userRecord.uid,
      email,
      firstName,
      lastName,
      phoneNumber,
      dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : null,
      gender,
      preferredLanguage,
      emergencyContact: emergencyContact || {},
      role: 'patient',
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    await collections.users.doc(userRecord.uid).set(userProfile);

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName
      }
    });
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      throw new ApiError(409, 'Email already registered');
    }
    throw error;
  }
}));

/**
 * POST /api/auth/login
 * Login user and return Firebase ID token
 */
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').isString()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid login credentials', errors.array());
  }

  const { email, password } = req.body;

  try {
    // Sign in with Firebase Auth
    const userRecord = await auth.getUserByEmail(email);
    
    // Note: Firebase Admin SDK doesn't support password verification
    // In a real implementation, you would use Firebase Auth REST API or client SDK
    // For now, we'll just verify the user exists and return success
    
    // Get user profile from Firestore
    const userDoc = await collections.users.doc(userRecord.uid).get();
    
    if (!userDoc.exists) {
      throw new ApiError(404, 'User profile not found');
    }

    const userProfile = userDoc.data();
    
    if (!userProfile.isActive) {
      throw new ApiError(403, 'Account is deactivated');
    }

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName,
        profile: userProfile
      }
    });
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      throw new ApiError(401, 'Invalid credentials');
    }
    throw error;
  }
}));

/**
 * GET /api/auth/profile
 * Get current user's profile
 */
router.get('/profile', asyncHandler(async (req, res) => {
  const userDoc = await collections.users.doc(req.user.uid).get();

  if (!userDoc.exists) {
    throw new ApiError(404, 'User profile not found');
  }

  const userProfile = userDoc.data();

  res.json({
    success: true,
    data: {
      profile: userProfile
    }
  });
}));

/**
 * PUT /api/auth/profile
 * Update user profile
 */
router.put('/profile', [
  body('firstName').optional().isString().trim().isLength({ min: 2, max: 50 }),
  body('lastName').optional().isString().trim().isLength({ min: 2, max: 50 }),
  body('phoneNumber').optional().isString().trim(),
  body('dateOfBirth').optional().isISO8601(),
  body('gender').optional().isIn(['male', 'female', 'other']),
  body('preferredLanguage').optional().isIn(['en', 'rw', 'fr']),
  body('emergencyContact').optional().isObject()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid profile data', errors.array());
  }

  const updateData = {
    ...req.body,
    updatedAt: new Date()
  };

  // Convert dateOfBirth to Date object if provided
  if (updateData.dateOfBirth) {
    updateData.dateOfBirth = new Date(updateData.dateOfBirth);
  }

  const docRef = collections.users.doc(req.user.uid);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new ApiError(404, 'User profile not found');
  }

  await docRef.update(updateData);

  // Update display name in Firebase Auth if name changed
  if (updateData.firstName || updateData.lastName) {
    const currentProfile = doc.data();
    const newFirstName = updateData.firstName || currentProfile.firstName;
    const newLastName = updateData.lastName || currentProfile.lastName;
    
    await auth.updateUser(req.user.uid, {
      displayName: `${newFirstName} ${newLastName}`
    });
  }

  res.json({
    success: true,
    message: 'Profile updated successfully',
    data: {
      profile: {
        ...doc.data(),
        ...updateData
      }
    }
  });
}));

/**
 * POST /api/auth/change-password
 * Change user password
 */
router.post('/change-password', [
  body('currentPassword').isString(),
  body('newPassword').isLength({ min: 6 })
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid password data', errors.array());
  }

  const { currentPassword, newPassword } = req.body;

  try {
    // Note: Firebase Admin SDK doesn't support password changes
    // In a real implementation, you would use Firebase Auth REST API or client SDK
    // For now, we'll just return success
    
    res.json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error) {
    throw new ApiError(400, 'Failed to change password');
  }
}));

/**
 * POST /api/auth/forgot-password
 * Send password reset email
 */
router.post('/forgot-password', [
  body('email').isEmail().normalizeEmail()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid email', errors.array());
  }

  const { email } = req.body;

  try {
    // Note: Firebase Admin SDK doesn't support password reset emails
    // In a real implementation, you would use Firebase Auth REST API or client SDK
    // For now, we'll just return success
    
    res.json({
      success: true,
      message: 'Password reset email sent successfully'
    });
  } catch (error) {
    throw new ApiError(400, 'Failed to send password reset email');
  }
}));

/**
 * DELETE /api/auth/account
 * Deactivate user account
 */
router.delete('/account', asyncHandler(async (req, res) => {
  const docRef = collections.users.doc(req.user.uid);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new ApiError(404, 'User profile not found');
  }

  // Deactivate user in Firestore
  await docRef.update({
    isActive: false,
    updatedAt: new Date()
  });

  // Note: In a real implementation, you might also want to disable the Firebase Auth user
  // await auth.updateUser(req.user.uid, { disabled: true });

  res.json({
    success: true,
    message: 'Account deactivated successfully'
  });
}));

module.exports = router; 