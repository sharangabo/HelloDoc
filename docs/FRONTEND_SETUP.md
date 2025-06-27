# HelloDoc - Flutter Frontend Setup

## Overview
The HelloDoc mobile application is built with Flutter, providing a cross-platform solution for iOS and Android devices. The app connects patients with healthcare facilities, offering real-time doctor availability and appointment booking capabilities.

## Prerequisites

### Required Software
- **Flutter SDK** (3.16.0 or higher)
- **Dart SDK** (3.2.0 or higher)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)
- **VS Code** (recommended editor)
- **Git**

### Flutter Installation
1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract to a desired location (e.g., `C:\flutter` on Windows, `/Users/username/flutter` on macOS)
3. Add Flutter to your PATH
4. Run `flutter doctor` to verify installation

### IDE Setup
1. Install Flutter and Dart extensions in VS Code
2. Install Android Studio with Android SDK
3. Configure Android emulator or connect physical device
4. For iOS development, install Xcode (macOS only)

## Project Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd rwanda-health-connect/frontend
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "rwanda-health-connect"
3. Enable Authentication, Firestore, and Cloud Functions

#### Configure Firebase for Flutter
1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Initialize Firebase in the project:
```bash
firebase init
```

4. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

5. Place configuration files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

#### Update Android Configuration
1. Update `android/app/build.gradle`:
```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

2. Update `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### Update iOS Configuration
1. Update `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

2. Run pod install:
```bash
cd ios
pod install
cd ..
```

### 4. Google Maps Configuration

#### Get API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Maps SDK for Android and iOS
4. Create API key with restrictions

#### Configure API Key
1. Update `lib/core/constants/app_constants.dart`:
```dart
static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
```

2. Android: Update `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

3. iOS: Update `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 5. Environment Configuration

#### Create Environment File
Create `lib/core/config/env.dart`:
```dart
class Env {
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const String firebaseProjectId = 'rwanda-health-connect';
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
}
```

#### Update API Configuration
Update `lib/core/constants/app_constants.dart` with your backend URL:
```dart
static const String baseUrl = 'http://your-backend-url.com/api';
```

## Running the Application

### Development Mode
```bash
flutter run
```

### Release Mode
```bash
flutter run --release
```

### Platform Specific
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── routes/
│   │   └── app_router.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── location_provider.dart
│   │   ├── appointment_provider.dart
│   │   ├── facility_provider.dart
│   │   └── notification_provider.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── location_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   └── utils/
│       ├── validators.dart
│       ├── helpers.dart
│       └── extensions.dart
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   ├── home/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   ├── facilities/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   ├── appointments/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── models/
│   └── profile/
│       ├── screens/
│       ├── widgets/
│       └── models/
├── shared/
│   ├── widgets/
│   ├── models/
│   └── constants/
└── main.dart
```

## Key Features Implementation

### 1. Multi-language Support
The app supports English, Kinyarwanda, and French:

```dart
// Localization setup
localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [
  Locale('en', 'US'),
  Locale('rw', 'RW'),
  Locale('fr', 'FR'),
],
```

### 2. GPS Location Services
```dart
// Location permission request
final permission = await Geolocator.requestPermission();
if (permission == LocationPermission.denied) {
  // Handle permission denied
}

// Get current location
final position = await Geolocator.getCurrentPosition();
```

### 3. Real-time Data
```dart
// Firestore real-time listeners
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('facilities')
      .snapshots(),
  builder: (context, snapshot) {
    // Handle real-time updates
  },
)
```

### 4. Push Notifications
```dart
// Initialize notifications
await FlutterLocalNotificationsPlugin().initialize(
  InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  ),
);
```

## Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS Archive
```bash
flutter build ios --release
```

## Deployment

### Google Play Store
1. Build app bundle: `flutter build appbundle`
2. Upload to Google Play Console
3. Configure store listing and release

### Apple App Store
1. Build iOS archive: `flutter build ios`
2. Archive in Xcode
3. Upload to App Store Connect

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Issues
```bash
flutter doctor --android-licenses
flutter clean
flutter pub get
```

#### 2. Firebase Configuration
- Verify `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Check Firebase project settings
- Ensure all required Firebase services are enabled

#### 3. Google Maps Issues
- Verify API key is correct
- Check API key restrictions
- Ensure Maps SDK is enabled in Google Cloud Console

#### 4. Build Issues
```bash
flutter clean
flutter pub get
flutter build apk --release
```

#### 5. iOS Specific Issues
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

## Performance Optimization

### 1. Image Optimization
- Use `cached_network_image` for network images
- Implement image compression
- Use appropriate image formats

### 2. State Management
- Use Provider for efficient state management
- Implement proper widget rebuilding
- Use `const` constructors where possible

### 3. Network Optimization
- Implement request caching
- Use pagination for large data sets
- Optimize API calls

### 4. Memory Management
- Dispose controllers properly
- Use weak references where appropriate
- Implement proper widget lifecycle management

## Security Considerations

### 1. API Security
- Use HTTPS for all API calls
- Implement proper token management
- Validate all user inputs

### 2. Data Protection
- Encrypt sensitive data
- Implement secure storage
- Follow GDPR compliance

### 3. Firebase Security
- Configure Firestore security rules
- Implement proper authentication
- Use Firebase App Check

## Monitoring and Analytics

### 1. Firebase Analytics
```dart
await FirebaseAnalytics.instance.logEvent(
  name: 'appointment_booked',
  parameters: {
    'facility_id': facilityId,
    'doctor_id': doctorId,
  },
);
```

### 2. Crash Reporting
```dart
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
);
```

### 3. Performance Monitoring
```dart
FirebasePerformance.instance.newTrace('appointment_booking');
```

## Support and Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [GitHub Issues](https://github.com/flutter/flutter/issues)

### Tools
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)
- [Flutter Performance](https://flutter.dev/docs/perf/ui-performance)
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools) 