# HelloDoc - Quick Setup Guide

## 🚀 Getting Started

This guide will help you set up the HelloDoc project locally for development.

## 📋 Prerequisites

### Required Software
- **Node.js** (v18 or higher)
- **Flutter SDK** (3.16.0 or higher)
- **Git**
- **Firebase CLI** (`npm install -g firebase-tools`)
- **Google Cloud Platform** account
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)

### Verify Installations
```bash
# Check Node.js
node --version
npm --version

# Check Flutter
flutter doctor

# Check Firebase CLI
firebase --version
```

## 🏗️ Project Structure

```
hellodoc/
├── backend/                 # Node.js Express API
│   ├── src/
│   │   ├── config/         # Firebase configuration
│   │   ├── middleware/     # Authentication & error handling
│   │   ├── routes/         # API endpoints
│   │   └── server.js       # Main server file
│   ├── package.json
│   └── env.example
├── frontend/               # Flutter mobile app
│   ├── lib/
│   │   ├── core/          # App configuration & utilities
│   │   ├── features/      # Feature modules
│   │   └── main.dart      # App entry point
│   └── pubspec.yaml
├── docs/                  # Documentation
└── README.md
```

## 🔧 Backend Setup

### 1. Navigate to Backend Directory
```bash
cd backend
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Firebase Setup
```bash
# Login to Firebase
firebase login

# Initialize Firebase project
firebase init

# Select:
# - Firestore
# - Authentication
# - Functions (optional)
```

### 4. Environment Configuration
```bash
# Copy environment template
cp env.example .env

# Edit .env with your configuration
nano .env
```

**Required Environment Variables:**
```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com

# Google Maps API
GOOGLE_MAPS_API_KEY=your-google-maps-api-key

# JWT Secret
JWT_SECRET=your-super-secret-jwt-key
```

### 5. Get Firebase Service Account Key
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > Service Accounts
4. Click "Generate new private key"
5. Download the JSON file
6. Copy the values to your `.env` file

### 6. Start Backend Server
```bash
# Development mode
npm run dev

# Production mode
npm start
```

**Verify Backend:**
- Health check: http://localhost:3000/health
- API docs: http://localhost:3000/api

## 📱 Frontend Setup

### 1. Navigate to Frontend Directory
```bash
cd frontend
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration

#### Android Setup
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/google-services.json`

#### iOS Setup
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/GoogleService-Info.plist`

### 4. Update API Configuration
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api';
static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

### 5. Run Flutter App
```bash
# Check connected devices
flutter devices

# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d <device-id>
```

## 🔑 API Keys Setup

### Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Maps SDK for Android and iOS
4. Create API key with restrictions:
   - Application restrictions: Android apps & iOS apps
   - API restrictions: Maps SDK for Android, Maps SDK for iOS

### Update API Key in Frontend
```dart
// lib/core/constants/app_constants.dart
static const String googleMapsApiKey = 'YOUR_ACTUAL_API_KEY';
```

## 🧪 Testing the Setup

### Backend API Tests
```bash
# Test health endpoint
curl http://localhost:3000/health

# Test API documentation
curl http://localhost:3000/api
```

### Frontend Tests
```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart
```

## 📊 Sample Data Setup

### Add Sample Facilities
```bash
# Using curl or Postman
curl -X POST http://localhost:3000/api/facilities \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Kigali Central Hospital",
    "type": "hospital",
    "location": {
      "latitude": -1.9441,
      "longitude": 30.0619
    },
    "address": "123 Main Street, Kigali",
    "city": "Kigali",
    "phone": "+250788123456",
    "specialties": ["General Medicine", "Surgery"]
  }'
```

### Add Sample Doctors
```bash
curl -X POST http://localhost:3000/api/doctors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Dr. Jane Smith",
    "facilityId": "facility_id_from_above",
    "specialties": ["General Medicine"],
    "qualifications": "MBBS, MD",
    "experience": 10,
    "phone": "+250788123456",
    "email": "jane.smith@hospital.rw"
  }'
```

## 🚨 Troubleshooting

### Common Issues

#### Backend Issues
```bash
# Port already in use
lsof -ti:3000 | xargs kill -9

# Firebase connection issues
firebase projects:list
firebase use your-project-id

# Environment variables not loading
echo $NODE_ENV
```

#### Frontend Issues
```bash
# Flutter doctor issues
flutter doctor --android-licenses
flutter clean
flutter pub get

# Firebase configuration issues
flutterfire configure

# Build issues
flutter clean
flutter pub get
flutter run
```

#### Firebase Issues
```bash
# Check Firebase project
firebase projects:list

# Check authentication
firebase login

# Initialize Firebase
firebase init
```

### Debug Commands
```bash
# Backend logs
npm run dev
# Check console output for errors

# Frontend logs
flutter run --verbose

# Firebase logs
firebase functions:log
```

## 📚 Next Steps

### 1. Explore the Codebase
- Review API endpoints in `backend/src/routes/`
- Check Flutter screens in `frontend/lib/features/`
- Understand the data models and providers

### 2. Add Features
- Implement new API endpoints
- Create new Flutter screens
- Add authentication flows
- Implement real-time updates

### 3. Testing
- Write unit tests for API endpoints
- Add widget tests for Flutter screens
- Implement integration tests

### 4. Deployment
- Deploy backend to cloud platform
- Build and publish mobile app
- Set up CI/CD pipeline

## 🔗 Useful Resources

### Documentation
- [API Documentation](docs/API_DOCUMENTATION.md)
- [Frontend Setup](docs/FRONTEND_SETUP.md)
- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)

### External Resources
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Express.js Documentation](https://expressjs.com/)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)

### Community Support
- [Flutter Community](https://flutter.dev/community)
- [Firebase Community](https://firebase.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

## 🎯 Development Workflow

### 1. Daily Development
```bash
# Start backend
cd backend && npm run dev

# Start frontend (in new terminal)
cd frontend && flutter run

# Make changes and test
# Backend changes auto-reload
# Frontend changes hot reload
```

### 2. Git Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push and create PR
git push origin feature/new-feature
```

### 3. Testing Workflow
```bash
# Backend tests
cd backend && npm test

# Frontend tests
cd frontend && flutter test

# Integration tests
flutter drive --target=test_driver/app.dart
```

## 🎉 Success!

Once you've completed this setup, you should have:
- ✅ Backend API running on http://localhost:3000
- ✅ Flutter app running on your device/emulator
- ✅ Firebase project configured
- ✅ Google Maps integration working
- ✅ Sample data loaded

You're now ready to develop the HelloDoc application! 🚀 