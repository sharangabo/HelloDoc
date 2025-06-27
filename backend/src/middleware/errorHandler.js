/**
 * Global error handling middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error('Error occurred:', err);

  // Default error response
  let statusCode = 500;
  let message = 'Internal server error';
  let error = 'Server Error';

  // Handle specific error types
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation failed';
    error = 'Validation Error';
  } else if (err.name === 'CastError') {
    statusCode = 400;
    message = 'Invalid ID format';
    error = 'Invalid Input';
  } else if (err.code === 11000) {
    statusCode = 409;
    message = 'Duplicate entry found';
    error = 'Conflict';
  } else if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
    error = 'Authentication Error';
  } else if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired';
    error = 'Authentication Error';
  } else if (err.status) {
    statusCode = err.status;
    message = err.message || message;
    error = err.error || error;
  }

  // Development environment - include stack trace
  const response = {
    error,
    message,
    timestamp: new Date().toISOString(),
    path: req.originalUrl
  };

  if (process.env.NODE_ENV === 'development') {
    response.stack = err.stack;
  }

  res.status(statusCode).json(response);
};

/**
 * Custom error class for API errors
 */
class ApiError extends Error {
  constructor(status, message, error = 'API Error') {
    super(message);
    this.status = status;
    this.error = error;
    this.name = 'ApiError';
  }
}

/**
 * Async error wrapper to catch async errors in route handlers
 */
const asyncHandler = (fn) => {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

module.exports = {
  errorHandler,
  ApiError,
  asyncHandler
}; 