const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { collections } = require('../config/firebase');
const { asyncHandler, ApiError } = require('../middleware/errorHandler');

const router = express.Router();

/**
 * GET /api/users/profile
 * Get current user's complete profile
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
 * PUT /api/users/profile
 * Update current user's profile
 */
router.put('/profile', [
  body('firstName').optional().isString().trim().isLength({ min: 2, max: 50 }),
  body('lastName').optional().isString().trim().isLength({ min: 2, max: 50 }),
  body('phoneNumber').optional().isString().trim(),
  body('dateOfBirth').optional().isISO8601(),
  body('gender').optional().isIn(['male', 'female', 'other']),
  body('preferredLanguage').optional().isIn(['en', 'rw', 'fr']),
  body('emergencyContact').optional().isObject(),
  body('address').optional().isObject(),
  body('medicalHistory').optional().isArray(),
  body('allergies').optional().isArray(),
  body('medications').optional().isArray()
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
 * GET /api/users/appointments
 * Get user's appointment history
 */
router.get('/appointments', [
  query('status').optional().isIn(['scheduled', 'confirmed', 'completed', 'cancelled', 'no-show']),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('page').optional().isInt({ min: 1 })
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid query parameters', errors.array());
  }

  const { status, limit = 20, page = 1 } = req.query;

  let query = collections.appointments.where('userId', '==', req.user.uid);

  if (status) {
    query = query.where('status', '==', status);
  }

  query = query.orderBy('appointmentDate', 'desc');

  const snapshot = await query.get();
  const appointments = [];

  snapshot.forEach(doc => {
    appointments.push({
      id: doc.id,
      ...doc.data()
    });
  });

  // Pagination
  const total = appointments.length;
  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + parseInt(limit);
  const paginatedAppointments = appointments.slice(startIndex, endIndex);

  res.json({
    success: true,
    data: {
      appointments: paginatedAppointments,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalItems: total,
        itemsPerPage: parseInt(limit),
        hasNextPage: endIndex < total,
        hasPrevPage: page > 1
      }
    }
  });
}));

/**
 * GET /api/users/favorites
 * Get user's favorite facilities
 */
router.get('/favorites', asyncHandler(async (req, res) => {
  const userDoc = await collections.users.doc(req.user.uid).get();

  if (!userDoc.exists) {
    throw new ApiError(404, 'User profile not found');
  }

  const userProfile = userDoc.data();
  const favoriteFacilityIds = userProfile.favoriteFacilities || [];

  if (favoriteFacilityIds.length === 0) {
    return res.json({
      success: true,
      data: {
        favorites: []
      }
    });
  }

  // Get favorite facilities details
  const favoriteFacilities = [];
  for (const facilityId of favoriteFacilityIds) {
    const facilityDoc = await collections.facilities.doc(facilityId).get();
    if (facilityDoc.exists) {
      favoriteFacilities.push({
        id: facilityDoc.id,
        ...facilityDoc.data()
      });
    }
  }

  res.json({
    success: true,
    data: {
      favorites: favoriteFacilities
    }
  });
}));

/**
 * POST /api/users/favorites/:facilityId
 * Add facility to favorites
 */
router.post('/favorites/:facilityId', asyncHandler(async (req, res) => {
  const { facilityId } = req.params;

  // Check if facility exists
  const facilityDoc = await collections.facilities.doc(facilityId).get();
  if (!facilityDoc.exists) {
    throw new ApiError(404, 'Facility not found');
  }

  const userDoc = await collections.users.doc(req.user.uid).get();
  if (!userDoc.exists) {
    throw new ApiError(404, 'User profile not found');
  }

  const userProfile = userDoc.data();
  const favoriteFacilities = userProfile.favoriteFacilities || [];

  if (favoriteFacilities.includes(facilityId)) {
    throw new ApiError(409, 'Facility already in favorites');
  }

  favoriteFacilities.push(facilityId);

  await collections.users.doc(req.user.uid).update({
    favoriteFacilities,
    updatedAt: new Date()
  });

  res.json({
    success: true,
    message: 'Facility added to favorites'
  });
}));

/**
 * DELETE /api/users/favorites/:facilityId
 * Remove facility from favorites
 */
router.delete('/favorites/:facilityId', asyncHandler(async (req, res) => {
  const { facilityId } = req.params;

  const userDoc = await collections.users.doc(req.user.uid).get();
  if (!userDoc.exists) {
    throw new ApiError(404, 'User profile not found');
  }

  const userProfile = userDoc.data();
  const favoriteFacilities = userProfile.favoriteFacilities || [];

  if (!favoriteFacilities.includes(facilityId)) {
    throw new ApiError(404, 'Facility not in favorites');
  }

  const updatedFavorites = favoriteFacilities.filter(id => id !== facilityId);

  await collections.users.doc(req.user.uid).update({
    favoriteFacilities: updatedFavorites,
    updatedAt: new Date()
  });

  res.json({
    success: true,
    message: 'Facility removed from favorites'
  });
}));

/**
 * GET /api/users/notifications
 * Get user's notifications
 */
router.get('/notifications', [
  query('isRead').optional().isBoolean(),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('page').optional().isInt({ min: 1 })
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid query parameters', errors.array());
  }

  const { isRead, limit = 20, page = 1 } = req.query;

  let query = collections.notifications.where('userId', '==', req.user.uid);

  if (isRead !== undefined) {
    query = query.where('isRead', '==', isRead === 'true');
  }

  query = query.orderBy('createdAt', 'desc');

  const snapshot = await query.get();
  const notifications = [];

  snapshot.forEach(doc => {
    notifications.push({
      id: doc.id,
      ...doc.data()
    });
  });

  // Pagination
  const total = notifications.length;
  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + parseInt(limit);
  const paginatedNotifications = notifications.slice(startIndex, endIndex);

  res.json({
    success: true,
    data: {
      notifications: paginatedNotifications,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalItems: total,
        itemsPerPage: parseInt(limit),
        hasNextPage: endIndex < total,
        hasPrevPage: page > 1
      }
    }
  });
}));

/**
 * PUT /api/users/notifications/:id/read
 * Mark notification as read
 */
router.put('/notifications/:id/read', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const docRef = collections.notifications.doc(id);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new ApiError(404, 'Notification not found');
  }

  const notification = doc.data();
  if (notification.userId !== req.user.uid) {
    throw new ApiError(403, 'Access denied');
  }

  await docRef.update({
    isRead: true,
    readAt: new Date()
  });

  res.json({
    success: true,
    message: 'Notification marked as read'
  });
}));

/**
 * PUT /api/users/notifications/read-all
 * Mark all notifications as read
 */
router.put('/notifications/read-all', asyncHandler(async (req, res) => {
  const unreadNotifications = await collections.notifications
    .where('userId', '==', req.user.uid)
    .where('isRead', '==', false)
    .get();

  const batch = collections.notifications.firestore.batch();
  unreadNotifications.forEach(doc => {
    batch.update(doc.ref, {
      isRead: true,
      readAt: new Date()
    });
  });

  await batch.commit();

  res.json({
    success: true,
    message: 'All notifications marked as read'
  });
}));

module.exports = router; 