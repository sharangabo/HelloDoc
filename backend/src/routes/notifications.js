const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { collections } = require('../config/firebase');
const { asyncHandler, ApiError } = require('../middleware/errorHandler');

const router = express.Router();

/**
 * GET /api/notifications
 * Get user's notifications with filtering
 */
router.get('/', [
  query('type').optional().isString().trim(),
  query('isRead').optional().isBoolean(),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('page').optional().isInt({ min: 1 })
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid query parameters', errors.array());
  }

  const { type, isRead, limit = 20, page = 1 } = req.query;

  let query = collections.notifications.where('userId', '==', req.user.uid);

  if (type) {
    query = query.where('type', '==', type);
  }

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
 * GET /api/notifications/:id
 * Get specific notification details
 */
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const doc = await collections.notifications.doc(id).get();

  if (!doc.exists) {
    throw new ApiError(404, 'Notification not found');
  }

  const notification = doc.data();

  if (notification.userId !== req.user.uid) {
    throw new ApiError(403, 'Access denied');
  }

  res.json({
    success: true,
    data: {
      notification: {
        id: doc.id,
        ...notification
      }
    }
  });
}));

/**
 * PUT /api/notifications/:id/read
 * Mark notification as read
 */
router.put('/:id/read', asyncHandler(async (req, res) => {
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
 * PUT /api/notifications/read-all
 * Mark all notifications as read
 */
router.put('/read-all', asyncHandler(async (req, res) => {
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

/**
 * DELETE /api/notifications/:id
 * Delete a notification
 */
router.delete('/:id', asyncHandler(async (req, res) => {
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

  await docRef.delete();

  res.json({
    success: true,
    message: 'Notification deleted successfully'
  });
}));

/**
 * DELETE /api/notifications
 * Delete all notifications for user
 */
router.delete('/', [
  query('type').optional().isString().trim(),
  query('isRead').optional().isBoolean()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid query parameters', errors.array());
  }

  const { type, isRead } = req.query;

  let query = collections.notifications.where('userId', '==', req.user.uid);

  if (type) {
    query = query.where('type', '==', type);
  }

  if (isRead !== undefined) {
    query = query.where('isRead', '==', isRead === 'true');
  }

  const notificationsToDelete = await query.get();

  const batch = collections.notifications.firestore.batch();
  notificationsToDelete.forEach(doc => {
    batch.delete(doc.ref);
  });

  await batch.commit();

  res.json({
    success: true,
    message: 'Notifications deleted successfully'
  });
}));

/**
 * GET /api/notifications/unread-count
 * Get count of unread notifications
 */
router.get('/unread-count', asyncHandler(async (req, res) => {
  const unreadSnapshot = await collections.notifications
    .where('userId', '==', req.user.uid)
    .where('isRead', '==', false)
    .get();

  res.json({
    success: true,
    data: {
      unreadCount: unreadSnapshot.size
    }
  });
}));

module.exports = router; 