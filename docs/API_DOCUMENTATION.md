# HelloDoc API Documentation

## Overview
The HelloDoc API provides endpoints for managing healthcare facilities, appointments, user authentication, and real-time doctor availability.

## Base URL
```
http://localhost:3000/api
```

## Authentication
The API uses Firebase Authentication with JWT tokens. Include the token in the Authorization header:
```
Authorization: Bearer <firebase_id_token>
```

## API Endpoints

### Authentication

#### POST /auth/register
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe",
  "phoneNumber": "+250788123456",
  "dateOfBirth": "1990-01-01",
  "gender": "male",
  "preferredLanguage": "en",
  "emergencyContact": {
    "name": "Jane Doe",
    "phone": "+250788123457",
    "relationship": "spouse"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "uid": "user_uid",
    "email": "user@example.com",
    "displayName": "John Doe"
  }
}
```

#### POST /auth/login
Authenticate user and get access token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "uid": "user_uid",
    "email": "user@example.com",
    "displayName": "John Doe",
    "profile": {
      "firstName": "John",
      "lastName": "Doe",
      "role": "patient"
    }
  }
}
```

#### GET /auth/profile
Get current user's profile.

**Response:**
```json
{
  "success": true,
  "data": {
    "profile": {
      "uid": "user_uid",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "phoneNumber": "+250788123456",
      "role": "patient",
      "preferredLanguage": "en"
    }
  }
}
```

### Facilities

#### GET /facilities/nearby
Find healthcare facilities within specified radius.

**Query Parameters:**
- `lat` (required): Latitude
- `lng` (required): Longitude
- `radius` (optional): Search radius in km (default: 20, max: 50)
- `specialty` (optional): Medical specialty filter
- `type` (optional): Facility type (hospital, clinic, pharmacy, laboratory)
- `limit` (optional): Number of results (default: 20, max: 50)

**Example:**
```
GET /facilities/nearby?lat=-1.9441&lng=30.0619&radius=10&type=hospital
```

**Response:**
```json
{
  "success": true,
  "data": {
    "facilities": [
      {
        "id": "facility_id",
        "name": "Kigali Central Hospital",
        "type": "hospital",
        "location": {
          "latitude": -1.9441,
          "longitude": 30.0619
        },
        "address": "123 Main Street, Kigali",
        "city": "Kigali",
        "phone": "+250788123456",
        "distance": 2.5,
        "estimatedTravelTime": 8,
        "rating": 4.5,
        "specialties": ["General Medicine", "Surgery"]
      }
    ],
    "totalFound": 15,
    "totalReturned": 10,
    "searchRadius": 10,
    "userLocation": {
      "latitude": -1.9441,
      "longitude": 30.0619
    }
  }
}
```

#### GET /facilities/:id
Get detailed information about a specific facility.

**Response:**
```json
{
  "success": true,
  "data": {
    "facility": {
      "id": "facility_id",
      "name": "Kigali Central Hospital",
      "type": "hospital",
      "location": {
        "latitude": -1.9441,
        "longitude": 30.0619
      },
      "address": "123 Main Street, Kigali",
      "city": "Kigali",
      "phone": "+250788123456",
      "email": "info@kch.rw",
      "operatingHours": {
        "monday": "08:00-18:00",
        "tuesday": "08:00-18:00"
      },
      "specialties": ["General Medicine", "Surgery"],
      "rating": 4.5,
      "reviewCount": 120
    },
    "doctors": [
      {
        "id": "doctor_id",
        "name": "Dr. Jane Smith",
        "specialties": ["General Medicine"],
        "isAvailable": true,
        "rating": 4.8
      }
    ],
    "doctorCount": 25
  }
}
```

### Doctors

#### GET /doctors
Get all doctors with optional filtering.

**Query Parameters:**
- `facilityId` (optional): Filter by facility
- `specialty` (optional): Filter by medical specialty
- `isAvailable` (optional): Filter by availability
- `limit` (optional): Number of results (default: 20, max: 50)
- `page` (optional): Page number (default: 1)

**Response:**
```json
{
  "success": true,
  "data": {
    "doctors": [
      {
        "id": "doctor_id",
        "name": "Dr. Jane Smith",
        "facilityId": "facility_id",
        "specialties": ["General Medicine"],
        "qualifications": "MBBS, MD",
        "experience": 10,
        "phone": "+250788123456",
        "email": "jane.smith@hospital.rw",
        "isAvailable": true,
        "rating": 4.8,
        "reviewCount": 45
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 5,
      "totalItems": 100,
      "itemsPerPage": 20,
      "hasNextPage": true,
      "hasPrevPage": false
    }
  }
}
```

#### GET /doctors/:id/availability
Get doctor's availability for a specific date.

**Query Parameters:**
- `date` (required): Date in ISO format (YYYY-MM-DD)
- `facilityId` (required): Facility ID

**Response:**
```json
{
  "success": true,
  "data": {
    "doctorId": "doctor_id",
    "date": "2024-01-15",
    "availableSlots": [
      "08:00",
      "08:30",
      "09:00",
      "09:30"
    ],
    "workingHours": {
      "start": "08:00",
      "end": "17:00"
    },
    "isAvailable": true
  }
}
```

### Appointments

#### GET /appointments
Get user's appointments with optional filtering.

**Query Parameters:**
- `status` (optional): Appointment status filter
- `startDate` (optional): Start date filter
- `endDate` (optional): End date filter
- `limit` (optional): Number of results (default: 20, max: 50)
- `page` (optional): Page number (default: 1)

**Response:**
```json
{
  "success": true,
  "data": {
    "appointments": [
      {
        "id": "appointment_id",
        "facilityId": "facility_id",
        "doctorId": "doctor_id",
        "appointmentDate": "2024-01-15T00:00:00.000Z",
        "appointmentTime": "09:00",
        "reason": "Regular checkup",
        "status": "scheduled",
        "preferredLanguage": "en",
        "notes": "Patient prefers morning appointments"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalItems": 5,
      "itemsPerPage": 20,
      "hasNextPage": false,
      "hasPrevPage": false
    }
  }
}
```

#### POST /appointments
Book a new appointment.

**Request Body:**
```json
{
  "facilityId": "facility_id",
  "doctorId": "doctor_id",
  "appointmentDate": "2024-01-15",
  "appointmentTime": "09:00",
  "reason": "Regular checkup",
  "preferredLanguage": "en",
  "notes": "Patient prefers morning appointments"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Appointment booked successfully",
  "data": {
    "id": "appointment_id",
    "userId": "user_uid",
    "facilityId": "facility_id",
    "doctorId": "doctor_id",
    "appointmentDate": "2024-01-15T00:00:00.000Z",
    "appointmentTime": "09:00",
    "reason": "Regular checkup",
    "status": "scheduled",
    "createdAt": "2024-01-10T10:30:00.000Z"
  }
}
```

#### PUT /appointments/:id
Update appointment (reschedule).

**Request Body:**
```json
{
  "appointmentDate": "2024-01-16",
  "appointmentTime": "10:00",
  "reason": "Updated reason for visit"
}
```

#### DELETE /appointments/:id
Cancel appointment.

**Response:**
```json
{
  "success": true,
  "message": "Appointment cancelled successfully"
}
```

#### GET /appointments/available-slots/:doctorId
Get available appointment slots for a doctor.

**Query Parameters:**
- `date` (required): Date in ISO format (YYYY-MM-DD)
- `facilityId` (required): Facility ID

**Response:**
```json
{
  "success": true,
  "data": {
    "doctorId": "doctor_id",
    "date": "2024-01-15",
    "availableSlots": [
      "08:00",
      "08:30",
      "09:00",
      "09:30",
      "10:00"
    ],
    "workingHours": {
      "start": "08:00",
      "end": "17:00"
    }
  }
}
```

### Notifications

#### GET /notifications
Get user's notifications.

**Query Parameters:**
- `type` (optional): Notification type filter
- `isRead` (optional): Read status filter
- `limit` (optional): Number of results (default: 20, max: 50)
- `page` (optional): Page number (default: 1)

**Response:**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "notification_id",
        "type": "appointment_created",
        "title": "Appointment Scheduled",
        "message": "Your appointment with Dr. Smith has been scheduled for January 15, 2024 at 9:00 AM",
        "isRead": false,
        "createdAt": "2024-01-10T10:30:00.000Z",
        "data": {
          "appointmentId": "appointment_id",
          "facilityId": "facility_id",
          "doctorId": "doctor_id"
        }
      }
    ],
    "pagination": {
      "currentPage": 1,
      "totalPages": 1,
      "totalItems": 5,
      "itemsPerPage": 20,
      "hasNextPage": false,
      "hasPrevPage": false
    }
  }
}
```

#### PUT /notifications/:id/read
Mark notification as read.

**Response:**
```json
{
  "success": true,
  "message": "Notification marked as read"
}
```

#### GET /notifications/unread-count
Get count of unread notifications.

**Response:**
```json
{
  "success": true,
  "data": {
    "unreadCount": 3
  }
}
```

## Error Responses

All endpoints return consistent error responses:

```json
{
  "error": "Error Type",
  "message": "Detailed error message",
  "timestamp": "2024-01-10T10:30:00.000Z",
  "path": "/api/endpoint"
}
```

### Common HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `500` - Internal Server Error

## Rate Limiting

The API implements rate limiting:
- 100 requests per 15 minutes per IP address
- Rate limit headers included in responses

## Pagination

List endpoints support pagination with the following parameters:
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 20, max: 50)

Pagination metadata is included in responses:
```json
{
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 100,
    "itemsPerPage": 20,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

## Data Models

### User Profile
```json
{
  "uid": "string",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "phoneNumber": "string",
  "dateOfBirth": "date",
  "gender": "male|female|other",
  "preferredLanguage": "en|rw|fr",
  "role": "patient|doctor|admin",
  "isActive": "boolean",
  "emergencyContact": "object",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Facility
```json
{
  "id": "string",
  "name": "string",
  "type": "hospital|clinic|pharmacy|laboratory",
  "location": {
    "latitude": "number",
    "longitude": "number"
  },
  "address": "string",
  "city": "string",
  "phone": "string",
  "email": "string",
  "specialties": ["string"],
  "operatingHours": "object",
  "rating": "number",
  "reviewCount": "number",
  "isActive": "boolean"
}
```

### Doctor
```json
{
  "id": "string",
  "name": "string",
  "facilityId": "string",
  "specialties": ["string"],
  "qualifications": "string",
  "experience": "number",
  "phone": "string",
  "email": "string",
  "workingHours": "object",
  "isAvailable": "boolean",
  "rating": "number",
  "reviewCount": "number"
}
```

### Appointment
```json
{
  "id": "string",
  "userId": "string",
  "facilityId": "string",
  "doctorId": "string",
  "appointmentDate": "date",
  "appointmentTime": "string",
  "reason": "string",
  "preferredLanguage": "en|rw|fr",
  "notes": "string",
  "status": "scheduled|confirmed|completed|cancelled|no-show",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Development Setup

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
```bash
cp env.example .env
# Edit .env with your configuration
```

3. Start development server:
```bash
npm run dev
```

4. Access API documentation:
```
http://localhost:3000/api
```

## Testing

Run tests:
```bash
npm test
```

Run tests with coverage:
```bash
npm run test:coverage
``` 