const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { collections } = require('../config/firebase');
const { asyncHandler, ApiError } = require('../middleware/errorHandler');
const { optionalAuth } = require('../middleware/auth');

const router = express.Router();

/**
 * GET /api/doctors
 * Get all doctors with optional filtering
 */
router.get('/', [
  query('facilityId').optional().isString().trim(),
  query('specialty').optional().isString().trim(),
  query('isAvailable').optional().isBoolean(),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('page').optional().isInt({ min: 1 })
], optionalAuth, asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid query parameters', errors.array());
  }

  const {
    facilityId, specialty, isAvailable, limit = 20, page = 1
  } = req.query;

  let query = collections.doctors.where('isActive', '==', true);

  if (facilityId) {
    query = query.where('facilityId', '==', facilityId);
  }

  if (specialty) {
    query = query.where('specialties', 'array-contains', specialty);
  }

  if (isAvailable !== undefined) {
    query = query.where('isAvailable', '==', isAvailable === 'true');
  }

  const snapshot = await query.get();
  const doctors = [];

  snapshot.forEach(doc => {
    doctors.push({
      id: doc.id,
      ...doc.data()
    });
  });

  // Pagination
  const total = doctors.length;
  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + parseInt(limit);
  const paginatedDoctors = doctors.slice(startIndex, endIndex);

  res.json({
    success: true,
    data: {
      doctors: paginatedDoctors,
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
 * GET /api/doctors/:id
 * Get detailed information about a specific doctor
 */
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const doc = await collections.doctors.doc(id).get();

  if (!doc.exists) {
    throw new ApiError(404, 'Doctor not found');
  }

  const doctor = doc.data();

  // Get facility information
  const facilityDoc = await collections.facilities.doc(doctor.facilityId).get();
  const facility = facilityDoc.exists ? facilityDoc.data() : null;

  // Get doctor's reviews
  const reviewsSnapshot = await collections.reviews
    .where('doctorId', '==', id)
    .orderBy('createdAt', 'desc')
    .limit(10)
    .get();

  const reviews = [];
  reviewsSnapshot.forEach(doc => {
    reviews.push({
      id: doc.id,
      ...doc.data()
    });
  });

  res.json({
    success: true,
    data: {
      doctor: {
        id: doc.id,
        ...doctor
      },
      facility,
      reviews,
      reviewCount: reviews.length
    }
  });
}));

/**
 * GET /api/doctors/:id/availability
 * Get doctor's availability for a specific date
 */
router.get('/:id/availability', [
  query('date').isISO8601(),
  query('facilityId').isString().trim()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid query parameters', errors.array());
  }

  const { id } = req.params;
  const { date, facilityId } = req.query;

  // Check if doctor exists and works at the facility
  const doctorDoc = await collections.doctors.doc(id).get();
  if (!doctorDoc.exists || !doctorDoc.data().isActive) {
    throw new ApiError(404, 'Doctor not found or inactive');
  }

  const doctor = doctorDoc.data();
  if (doctor.facilityId !== facilityId) {
    throw new ApiError(400, 'Doctor does not work at the specified facility');
  }

  // Get doctor's working hours
  const workingHours = doctor.workingHours || {
    start: '08:00',
    end: '17:00',
    days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']
  };

  // Check if the requested date is a working day
  const dayOfWeek = new Date(date).toLocaleDateString('en-US', { weekday: 'lowercase' });
  if (!workingHours.days.includes(dayOfWeek)) {
    throw new ApiError(400, 'Doctor does not work on this day');
  }

  // Get booked appointments for this doctor on this date
  const bookedAppointments = await collections.appointments
    .where('doctorId', '==', id)
    .where('appointmentDate', '==', new Date(date))
    .where('status', 'in', ['scheduled', 'confirmed'])
    .get();

  const bookedTimes = new Set();
  bookedAppointments.forEach(doc => {
    bookedTimes.add(doc.data().appointmentTime);
  });

  // Generate available time slots
  const availableSlots = [];
  const startTime = new Date(`2000-01-01T${workingHours.start}`);
  const endTime = new Date(`2000-01-01T${workingHours.end}`);
  const slotDuration = 30; // 30 minutes per slot

  while (startTime < endTime) {
    const timeSlot = startTime.toTimeString().slice(0, 5);
    if (!bookedTimes.has(timeSlot)) {
      availableSlots.push(timeSlot);
    }
    startTime.setMinutes(startTime.getMinutes() + slotDuration);
  }

  res.json({
    success: true,
    data: {
      doctorId: id,
      date,
      availableSlots,
      workingHours: {
        start: workingHours.start,
        end: workingHours.end
      },
      isAvailable: doctor.isAvailable
    }
  });
}));

/**
 * POST /api/doctors
 * Create a new doctor (Admin only)
 */
router.post('/', [
  body('name').isString().trim().isLength({ min: 2, max: 100 }),
  body('facilityId').isString().trim(),
  body('specialties').isArray(),
  body('qualifications').isString().trim(),
  body('experience').isInt({ min: 0 }),
  body('phone').isString().trim(),
  body('email').isEmail(),
  body('workingHours').optional().isObject(),
  body('bio').optional().isString().trim(),
  body('languages').optional().isArray()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid doctor data', errors.array());
  }

  const doctorData = {
    ...req.body,
    isActive: true,
    isAvailable: true,
    rating: 0,
    reviewCount: 0,
    createdAt: new Date(),
    updatedAt: new Date()
  };

  // Verify facility exists
  const facilityDoc = await collections.facilities.doc(doctorData.facilityId).get();
  if (!facilityDoc.exists) {
    throw new ApiError(404, 'Facility not found');
  }

  const docRef = await collections.doctors.add(doctorData);

  res.status(201).json({
    success: true,
    message: 'Doctor created successfully',
    data: {
      id: docRef.id,
      ...doctorData
    }
  });
}));

/**
 * PUT /api/doctors/:id
 * Update doctor information (Admin only)
 */
router.put('/:id', [
  body('name').optional().isString().trim().isLength({ min: 2, max: 100 }),
  body('facilityId').optional().isString().trim(),
  body('specialties').optional().isArray(),
  body('qualifications').optional().isString().trim(),
  body('experience').optional().isInt({ min: 0 }),
  body('phone').optional().isString().trim(),
  body('email').optional().isEmail(),
  body('workingHours').optional().isObject(),
  body('bio').optional().isString().trim(),
  body('languages').optional().isArray(),
  body('isAvailable').optional().isBoolean(),
  body('isActive').optional().isBoolean()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid doctor data', errors.array());
  }

  const { id } = req.params;
  const updateData = {
    ...req.body,
    updatedAt: new Date()
  };

  const docRef = collections.doctors.doc(id);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new ApiError(404, 'Doctor not found');
  }

  // Verify facility exists if facilityId is being updated
  if (updateData.facilityId) {
    const facilityDoc = await collections.facilities.doc(updateData.facilityId).get();
    if (!facilityDoc.exists) {
      throw new ApiError(404, 'Facility not found');
    }
  }

  await docRef.update(updateData);

  res.json({
    success: true,
    message: 'Doctor updated successfully',
    data: {
      id,
      ...updateData
    }
  });
}));

/**
 * GET /api/doctors/specialties
 * Get all available medical specialties
 */
router.get('/specialties/list', asyncHandler(async (req, res) => {
  const snapshot = await collections.specialties.get();
  const specialties = [];

  snapshot.forEach(doc => {
    specialties.push({
      id: doc.id,
      ...doc.data()
    });
  });

  res.json({
    success: true,
    data: {
      specialties
    }
  });
}));

module.exports = router; 