class AppConstants {
  // App Information
  static const String appName = 'HelloDoc';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Connect with healthcare facilities and doctors';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api';
  static const int apiTimeout = 30000; // 30 seconds
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String facilitiesEndpoint = '/facilities';
  static const String doctorsEndpoint = '/doctors';
  static const String appointmentsEndpoint = '/appointments';
  static const String usersEndpoint = '/users';
  static const String notificationsEndpoint = '/notifications';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'rwanda-health-connect';
  
  // Google Maps Configuration
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Location Configuration
  static const double defaultLatitude = -1.9441; // Kigali coordinates
  static const double defaultLongitude = 30.0619;
  static const double searchRadius = 10.0; // km
  static const double maxSearchRadius = 50.0; // km
  
  // Appointment Configuration
  static const int appointmentDuration = 30; // minutes
  static const int maxAdvanceBookingDays = 30;
  static const int minCancellationHours = 24;
  
  // Pagination
  static const int pageSize = 20;
  static const int maxRetries = 3;
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 1);
  static const Duration locationCacheExpiry = Duration(minutes: 5);
  
  // Notification Configuration
  static const String notificationChannelId = 'hellodoc_notifications';
  static const String notificationChannelName = 'HelloDoc Notifications';
  static const String notificationChannelDescription = 'Notifications from HelloDoc app';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  static const String locationKey = 'last_location';
  static const String onboardingKey = 'onboarding_completed';
  
  // Supported Languages
  static const List<String> supportedLanguages = ['en', 'rw', 'fr'];
  static const String defaultLanguage = 'en';
  
  // Facility Types
  static const List<String> facilityTypes = [
    'hospital',
    'clinic',
    'pharmacy',
    'laboratory'
  ];
  
  // Appointment Status
  static const List<String> appointmentStatuses = [
    'scheduled',
    'confirmed',
    'completed',
    'cancelled',
    'no-show'
  ];
  
  // User Roles
  static const List<String> userRoles = [
    'patient',
    'doctor',
    'admin'
  ];
  
  // Default Values
  static const String defaultCountry = 'RW';
  
  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String emailAlreadyExists = 'Email already exists.';
  static const String weakPassword = 'Password is too weak.';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registrationSuccess = 'Registration successful!';
  static const String appointmentBooked = 'Appointment booked successfully!';
  static const String appointmentCancelled = 'Appointment cancelled successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
  
  // Validation Messages
  static const String emailRequired = 'Email is required.';
  static const String validEmailRequired = 'Please enter a valid email address.';
  static const String passwordRequired = 'Password is required.';
  static const String passwordMinLength = 'Password must be at least 6 characters.';
  static const String nameRequired = 'Name is required.';
  static const String phoneRequired = 'Phone number is required.';
  static const String validPhoneRequired = 'Please enter a valid phone number.';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Colors (will be moved to theme)
  static const int primaryColorValue = 0xFF1E88E5;
  static const int accentColorValue = 0xFFFF6B35;
  static const int successColorValue = 0xFF4CAF50;
  static const int errorColorValue = 0xFFF44336;
  static const int warningColorValue = 0xFFFF9800;
  
  // Rwanda-specific constants
  static const String rwandaCountryCode = '+250';
  static const String rwandaCurrency = 'RWF';
  static const List<String> rwandaCities = [
    'Kigali',
    'Butare',
    'Gitarama',
    'Ruhengeri',
    'Gisenyi',
    'Byumba',
    'Cyangugu',
    'Kibuye',
    'Kibungo',
    'Nyanza'
  ];
  
  // Medical specialties (common in Rwanda)
  static const List<String> medicalSpecialties = [
    'General Medicine',
    'Pediatrics',
    'Obstetrics & Gynecology',
    'Surgery',
    'Cardiology',
    'Dermatology',
    'Ophthalmology',
    'Dentistry',
    'Psychiatry',
    'Orthopedics',
    'Neurology',
    'Oncology',
    'Emergency Medicine',
    'Family Medicine',
    'Internal Medicine'
  ];
} 