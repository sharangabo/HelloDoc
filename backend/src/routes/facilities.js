const express = require('express');
const { body, query, validationResult } = require('express-validator');
const { collections } = require('../config/firebase');
const { asyncHandler, ApiError } = require('../middleware/errorHandler');
const { optionalAuth } = require('../middleware/auth');

const router = express.Router();

/**
 * Calculate distance between two points using Haversine formula
 */
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371; // Earth's radius in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

/**
 * GET /api/facilities/nearby
 * Find healthcare facilities within specified radius
 */
router.get('/nearby', [
  query('lat').isFloat({ min: -90, max: 90 }).withMessage('Valid latitude required'),
  query('lng').isFloat({ min: -180, max: 180 }).withMessage('Valid longitude required'),
  query('radius').optional().isFloat({ min: 0.1, max: 50 }).withMessage('Radius must be between 0.1 and 50 km'),
  query('specialty').optional().isString().trim(),
  query('type').optional().isIn(['hospital', 'clinic', 'pharmacy', 'laboratory']),
  query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1 and 50')
], optionalAuth, asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid input parameters', errors.array());
  }

  const {
    lat, lng, radius = 20, specialty, type, limit = 20
  } = req.query;

  const userLat = parseFloat(lat);
  const userLng = parseFloat(lng);
  const searchRadius = parseFloat(radius);
  const resultLimit = parseInt(limit);

  // Build query
  let query = collections.facilities.where('isActive', '==', true);

  if (type) {
    query = query.where('type', '==', type);
  }

  if (specialty) {
    query = query.where('specialties', 'array-contains', specialty);
  }

  const snapshot = await query.get();
  const facilities = [];

  snapshot.forEach(doc => {
    const facility = doc.data();
    const distance = calculateDistance(
      userLat, userLng,
      facility.location.latitude,
      facility.location.longitude
    );

    // Only include facilities within the specified radius
    if (distance <= searchRadius) {
      facilities.push({
        id: doc.id,
        ...facility,
        distance: Math.round(distance * 100) / 100, // Round to 2 decimal places
        estimatedTravelTime: Math.round(distance * 3) // Rough estimate: 3 minutes per km
      });
    }
  });

  // Sort by distance and limit results
  facilities.sort((a, b) => a.distance - b.distance);
  const limitedFacilities = facilities.slice(0, resultLimit);

  res.json({
    success: true,
    data: {
      facilities: limitedFacilities,
      totalFound: facilities.length,
      totalReturned: limitedFacilities.length,
      searchRadius: searchRadius,
      userLocation: { latitude: userLat, longitude: userLng }
    }
  });
}));

/**
 * GET /api/facilities/:id
 * Get detailed information about a specific facility
 */
router.get('/:id', asyncHandler(async (req, res) => {
  const { id } = req.params;

  const doc = await collections.facilities.doc(id).get();

  if (!doc.exists) {
    throw new ApiError(404, 'Facility not found');
  }

  const facility = doc.data();

  // Get doctors at this facility
  const doctorsSnapshot = await collections.doctors
    .where('facilityId', '==', id)
    .where('isActive', '==', true)
    .get();

  const doctors = [];
  doctorsSnapshot.forEach(doc => {
    doctors.push({
      id: doc.id,
      ...doc.data()
    });
  });

  res.json({
    success: true,
    data: {
      facility: {
        id: doc.id,
        ...facility
      },
      doctors: doctors,
      doctorCount: doctors.length
    }
  });
}));

/**
 * GET /api/facilities
 * Get all facilities with optional filtering
 */
router.get('/', [
  query('type').optional().isIn(['hospital', 'clinic', 'pharmacy', 'laboratory']),
  query('specialty').optional().isString().trim(),
  query('city').optional().isString().trim(),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('page').optional().isInt({ min: 1 })
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid query parameters', errors.array());
  }

  const {
    type, specialty, city, limit = 20, page = 1
  } = req.query;

  let query = collections.facilities.where('isActive', '==', true);

  if (type) {
    query = query.where('type', '==', type);
  }

  if (city) {
    query = query.where('city', '==', city);
  }

  const snapshot = await query.get();
  const facilities = [];

  snapshot.forEach(doc => {
    const facility = doc.data();
    
    // Filter by specialty if specified
    if (specialty && (!facility.specialties || !facility.specialties.includes(specialty))) {
      return;
    }

    facilities.push({
      id: doc.id,
      ...facility
    });
  });

  // Pagination
  const total = facilities.length;
  const startIndex = (page - 1) * limit;
  const endIndex = startIndex + parseInt(limit);
  const paginatedFacilities = facilities.slice(startIndex, endIndex);

  res.json({
    success: true,
    data: {
      facilities: paginatedFacilities,
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
 * POST /api/facilities
 * Create a new healthcare facility (Admin only)
 */
router.post('/', [
  body('name').isString().trim().isLength({ min: 2, max: 100 }),
  body('type').isIn(['hospital', 'clinic', 'pharmacy', 'laboratory']),
  body('location.latitude').isFloat({ min: -90, max: 90 }),
  body('location.longitude').isFloat({ min: -180, max: 180 }),
  body('address').isString().trim().isLength({ min: 5, max: 200 }),
  body('city').isString().trim().isLength({ min: 2, max: 50 }),
  body('phone').isString().trim(),
  body('email').optional().isEmail(),
  body('specialties').optional().isArray(),
  body('operatingHours').optional().isObject(),
  body('description').optional().isString().trim()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid facility data', errors.array());
  }

  const facilityData = {
    ...req.body,
    isActive: true,
    createdAt: new Date(),
    updatedAt: new Date(),
    rating: 0,
    reviewCount: 0
  };

  const docRef = await collections.facilities.add(facilityData);

  res.status(201).json({
    success: true,
    message: 'Facility created successfully',
    data: {
      id: docRef.id,
      ...facilityData
    }
  });
}));

/**
 * PUT /api/facilities/:id
 * Update facility information (Admin only)
 */
router.put('/:id', [
  body('name').optional().isString().trim().isLength({ min: 2, max: 100 }),
  body('type').optional().isIn(['hospital', 'clinic', 'pharmacy', 'laboratory']),
  body('location.latitude').optional().isFloat({ min: -90, max: 90 }),
  body('location.longitude').optional().isFloat({ min: -180, max: 180 }),
  body('address').optional().isString().trim().isLength({ min: 5, max: 200 }),
  body('city').optional().isString().trim().isLength({ min: 2, max: 50 }),
  body('phone').optional().isString().trim(),
  body('email').optional().isEmail(),
  body('specialties').optional().isArray(),
  body('operatingHours').optional().isObject(),
  body('description').optional().isString().trim(),
  body('isActive').optional().isBoolean()
], asyncHandler(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ApiError(400, 'Invalid facility data', errors.array());
  }

  const { id } = req.params;
  const updateData = {
    ...req.body,
    updatedAt: new Date()
  };

  const docRef = collections.facilities.doc(id);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new ApiError(404, 'Facility not found');
  }

  await docRef.update(updateData);

  res.json({
    success: true,
    message: 'Facility updated successfully',
    data: {
      id,
      ...updateData
    }
  });
}));

module.exports = router; 