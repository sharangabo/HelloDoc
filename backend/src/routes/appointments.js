const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { collections } = require('../config/firebase');
const { asyncHandler, ApiError } = require('../middleware/errorHandler');
const moment = require('moment');

const router = express.Router();

/**
 * GET /api/appointments
 * Get user's appointments with optional filtering
 */
router.get('/', [
  query('status').optional().isIn(['scheduled', 'confirmed', 'completed', 'cancelled', 'no-show']),
  query('startDate').optional().isISO8601(),
  query('endDate').optional().isISO8601(),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('page').optional().isInt({ min: 1 })
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid query parameters', errors.array());
  }

  const {
    status, startDate, endDate, limit = 20, page = 1
  } = req.query;

  let query = collections.appointments.where('userId', '==', req.user.uid);

  if (status) {
    query = query.where('status', '==', status);
  }

  if (startDate) {
    query = query.where('appointmentDate', '>=', new Date(startDate));
  }

  if (endDate) {
    query = query.where('appointmentDate', '<=', new Date(endDate));
  }

  // Order by appointment date
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
 * GET /api/appointments/:id
 * Get specific appointment details
 */
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const doc = await collections.appointments.doc(id).get();

  if (!doc.exists) {
    throw new ApiError(404, 'Appointment not found');
  }

  const appointment = doc.data();

  // Check if user owns this appointment or is admin
  if (appointment.userId !== req.user.uid) {
    throw new ApiError(403, 'Access denied');
  }

  // Get facility and doctor details
  const [facilityDoc, doctorDoc] = await Promise.all([
    collections.facilities.doc(appointment.facilityId).get(),
    collections.doctors.doc(appointment.doctorId).get()
  ]);

  const facility = facilityDoc.exists ? facilityDoc.data() : null;
  const doctor = doctorDoc.exists ? doctorDoc.data() : null;

  res.json({
    success: true,
    data: {
      appointment: {
        id: doc.id,
        ...appointment
      },
      facility,
      doctor
    }
  });
}));

/**
 * POST /api/appointments
 * Book a new appointment
 */
router.post('/', [
  body('facilityId').isString().trim(),
  body('doctorId').isString().trim(),
  body('appointmentDate').isISO8601(),
  body('appointmentTime').matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  body('reason').isString().trim().isLength({ min: 5, max: 500 }),
  body('preferredLanguage').optional().isIn(['en', 'rw', 'fr']),
  body('notes').optional().isString().trim().isLength({ max: 1000 })
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid appointment data', errors.array());
  }

  const {
    facilityId, doctorId, appointmentDate, appointmentTime, reason, preferredLanguage = 'en', notes
  } = req.body;

  // Validate appointment date (must be in the future)
  const appointmentDateTime = moment(`${appointmentDate} ${appointmentTime}`);
  if (appointmentDateTime.isBefore(moment())) {
    throw new ApiError(400, 'Appointment date must be in the future');
  }

  // Check if facility exists and is active
  const facilityDoc = await collections.facilities.doc(facilityId).get();
  if (!facilityDoc.exists || !facilityDoc.data().isActive) {
    throw new ApiError(404, 'Facility not found or inactive');
  }

  // Check if doctor exists and is active
  const doctorDoc = await collections.doctors.doc(doctorId).get();
  if (!doctorDoc.exists || !doctorDoc.data().isActive) {
    throw new ApiError(404, 'Doctor not found or inactive');
  }

  // Check if doctor works at the specified facility
  if (doctorDoc.data().facilityId !== facilityId) {
    throw new ApiError(400, 'Doctor does not work at the specified facility');
  }

  // Check for conflicting appointments (same doctor, same time)
  const appointmentStart = appointmentDateTime.toDate();
  const appointmentEnd = appointmentDateTime.add(30, 'minutes').toDate(); // 30-minute slot

  const conflictingAppointments = await collections.appointments
    .where('doctorId', '==', doctorId)
    .where('status', 'in', ['scheduled', 'confirmed'])
    .where('appointmentDate', '==', appointmentDate)
    .where('appointmentTime', '==', appointmentTime)
    .get();

  if (!conflictingAppointments.empty) {
    throw new ApiError(409, 'This time slot is already booked');
  }

  // Create appointment
  const appointmentData = {
    userId: req.user.uid,
    facilityId,
    doctorId,
    appointmentDate: new Date(appointmentDate),
    appointmentTime,
    reason,
    preferredLanguage,
    notes: notes || '',
    status: 'scheduled',
    createdAt: new Date(),
    updatedAt: new Date()
  };

  const docRef = await collections.appointments.add(appointmentData);

  // Create notification for the user
  await collections.notifications.add({
    userId: req.user.uid,
    type: 'appointment_created',
    title: 'Appointment Scheduled',
    message: `Your appointment with Dr. ${doctorDoc.data().name} has been scheduled for ${appointmentDateTime.format('MMMM Do YYYY, h:mm a')}`,
    data: {
      appointmentId: docRef.id,
      facilityId,
      doctorId
    },
    isRead: false,
    createdAt: new Date()
  });

  res.status(201).json({
    success: true,
    message: 'Appointment booked successfully',
    data: {
      id: docRef.id,
      ...appointmentData
    }
  });
}));

/**
 * PUT /api/appointments/:id
 * Update appointment (reschedule)
 */
router.put('/:id', [
  body('appointmentDate').optional().isISO8601(),
  body('appointmentTime').optional().matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/),
  body('reason').optional().isString().trim().isLength({ min: 5, max: 500 }),
  body('notes').optional().isString().trim().isLength({ max: 1000 })
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid appointment data', errors.array());
  }

  const { id } = req.params;
  const { appointmentDate, appointmentTime, reason, notes } = req.body;

  const docRef = collections.appointments.doc(id);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new ApiError(404, 'Appointment not found');
  }

  const appointment = doc.data();

  // Check if user owns this appointment
  if (appointment.userId !== req.user.uid) {
    throw new ApiError(403, 'Access denied');
  }

  // Check if appointment can be modified (not completed or cancelled)
  if (['completed', 'cancelled'].includes(appointment.status)) {
    throw new ApiError(400, 'Cannot modify completed or cancelled appointments');
  }

  const updateData = {
    updatedAt: new Date()
  };

  // Validate new appointment date if provided
  if (appointmentDate && appointmentTime) {
    const newAppointmentDateTime = moment(`${appointmentDate} ${appointmentTime}`);
    if (newAppointmentDateTime.isBefore(moment())) {
      throw new ApiError(400, 'Appointment date must be in the future');
    }

    // Check for conflicting appointments
    const conflictingAppointments = await collections.appointments
      .where('doctorId', '==', appointment.doctorId)
      .where('status', 'in', ['scheduled', 'confirmed'])
      .where('appointmentDate', '==', appointmentDate)
      .where('appointmentTime', '==', appointmentTime)
      .get();

    if (!conflictingAppointments.empty) {
      const conflictDoc = conflictingAppointments.docs[0];
      if (conflictDoc.id !== id) {
        throw new ApiError(409, 'This time slot is already booked');
      }
    }

    updateData.appointmentDate = new Date(appointmentDate);
    updateData.appointmentTime = appointmentTime;
  }

  if (reason) {
    updateData.reason = reason;
  }

  if (notes !== undefined) {
    updateData.notes = notes;
  }

  await docRef.update(updateData);

  res.json({
    success: true,
    message: 'Appointment updated successfully',
    data: {
      id,
      ...updateData
    }
  });
}));

/**
 * DELETE /api/appointments/:id
 * Cancel appointment
 */
router.delete('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const docRef = collections.appointments.doc(id);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new ApiError(404, 'Appointment not found');
  }

  const appointment = doc.data();

  // Check if user owns this appointment
  if (appointment.userId !== req.user.uid) {
    throw new ApiError(403, 'Access denied');
  }

  // Check if appointment can be cancelled
  if (['completed', 'cancelled'].includes(appointment.status)) {
    throw new ApiError(400, 'Appointment cannot be cancelled');
  }

  // Check if appointment is within 24 hours
  const appointmentDateTime = moment(`${appointment.appointmentDate.toDate().toISOString().split('T')[0]} ${appointment.appointmentTime}`);
  const hoursUntilAppointment = appointmentDateTime.diff(moment(), 'hours');
  
  if (hoursUntilAppointment < 24) {
    throw new ApiError(400, 'Appointments can only be cancelled at least 24 hours in advance');
  }

  await docRef.update({
    status: 'cancelled',
    updatedAt: new Date()
  });

  res.json({
    success: true,
    message: 'Appointment cancelled successfully'
  });
}));

/**
 * GET /api/appointments/available-slots/:doctorId
 * Get available appointment slots for a doctor
 */
router.get('/available-slots/:doctorId', [
  query('date').isISO8601(),
  query('facilityId').isString().trim()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid query parameters', errors.array());
  }

  const { doctorId } = req.params;
  const { date, facilityId } = req.query;

  // Check if doctor exists and works at the facility
  const doctorDoc = await collections.doctors.doc(doctorId).get();
  if (!doctorDoc.exists || !doctorDoc.data().isActive) {
    throw new ApiError(404, 'Doctor not found or inactive');
  }

  if (doctorDoc.data().facilityId !== facilityId) {
    throw new ApiError(400, 'Doctor does not work at the specified facility');
  }

  // Get doctor's working hours
  const doctor = doctorDoc.data();
  const workingHours = doctor.workingHours || {
    start: '08:00',
    end: '17:00',
    days: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday']
  };

  // Check if the requested date is a working day
  const dayOfWeek = moment(date).format('dddd').toLowerCase();
  if (!workingHours.days.includes(dayOfWeek)) {
    throw new ApiError(400, 'Doctor does not work on this day');
  }

  // Get booked appointments for this doctor on this date
  const bookedAppointments = await collections.appointments
    .where('doctorId', '==', doctorId)
    .where('appointmentDate', '==', new Date(date))
    .where('status', 'in', ['scheduled', 'confirmed'])
    .get();

  const bookedTimes = new Set();
  bookedAppointments.forEach(doc => {
    bookedTimes.add(doc.data().appointmentTime);
  });

  // Generate available time slots
  const availableSlots = [];
  const startTime = moment(workingHours.start, 'HH:mm');
  const endTime = moment(workingHours.end, 'HH:mm');
  const slotDuration = 30; // 30 minutes per slot

  while (startTime.isBefore(endTime)) {
    const timeSlot = startTime.format('HH:mm');
    if (!bookedTimes.has(timeSlot)) {
      availableSlots.push(timeSlot);
    }
    startTime.add(slotDuration, 'minutes');
  }

  res.json({
    success: true,
    data: {
      doctorId,
      date,
      availableSlots,
      workingHours: {
        start: workingHours.start,
        end: workingHours.end
      }
    }
  });
}));

module.exports = router; 