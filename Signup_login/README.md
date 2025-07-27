# HelloDoc

A cross-platform Flutter application for booking medical appointments, with multi-language support and a modern, user-friendly interface.



## 📖 Description

**HelloDoc** is a mobile and web application that allows users to:
- Sign up and log in securely
- Book medical appointments
- View a dashboard with user information
- Switch between light and dark mode
- Use the app in English, French, or Kinyarwanda
- (Planned) Find hospitals, check doctor availability, and view wait times

The app is built with Flutter and Firebase, supporting Android, iOS, and web platforms.



## 🔗 GitHub Repository

[GitHub Repo Link](https://github.com/sharangabo/HelloDoc)




## ⚙️ Setup & Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Firebase Project](https://console.firebase.google.com/)
- Android Studio or Xcode (for mobile development)
- [Easy Localization](https://pub.dev/packages/easy_localization), [Provider](https://pub.dev/packages/provider), [Google Fonts](https://pub.dev/packages/google_fonts), [Firebase Auth](https://pub.dev/packages/firebase_auth)

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Firebase setup:**
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`
   - Configure Firebase in your project as per [FlutterFire docs](https://firebase.flutter.dev/docs/overview/)

4. **Localization:**
   - The app supports English, French, and Kinyarwanda.
   - Translation files are in `assets/translations/`.

5. **Run the app:**
   - For Android: `flutter run`
   - For iOS: `flutter run`
   - For Web: `flutter run -d chrome`



## 🎨 Designs

### Figma Mockups

- [Figma Design Link](https://www.figma.com/file/your-figma-link)
  *Replace with your actual Figma link.*

### Screenshots

| Login Screen | Home Dashboard | Appointment Booking |
|--------------|---------------|--------------------|
| ![Login]() | ![Home]() | ![Booking]() |





## 🛠️ Deployment Plan

1. **Testing:**
   - Run `flutter test` to execute widget and unit tests.
   - Manually test on Android, iOS, and Web.

2. **Build:**
   - Android: `flutter build apk`
   - iOS: `flutter build ios`
   - Web: `flutter build web`

3. **Deployment:**
   - **Android:** Upload APK to Google Play Console.
   - **iOS:** Upload via Xcode to App Store Connect.
   - **Web:** Deploy `build/web` to Firebase Hosting, Netlify, or Vercel.

4. **Continuous Integration (Optional):**
   - Set up GitHub Actions or other CI/CD tools for automated builds and tests.



## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.


## 🚀 New Features & Major Changes (2024 Update)

### App Rebranding
- The application is now called **Hospital Near Me** (formerly HelloDoc).
- All references to "HelloDoc" in the UI and codebase have been updated to reflect the new name and branding.

### New & Improved Functionality
- **Modern Authentication:**  
  - Sign up and sign in with Email/Password, Google, and Phone Number (using Firebase Authentication).
  - Terms and Conditions agreement required during sign up.

- **Navigation Drawer & Categories:**  
  - A new navigation drawer provides quick access to hospital categories such as Hospital, Ambulance, Blood Test, Free Eye Checkup, Dental Clinic, Blood Bank, Eye Specialist, Skin Doctor, Pet Specialist, Lab, Clinics, and Medical Records.

- **Hospital Search & Filtering:**  
  - Search bar and filter chips allow users to quickly find hospitals and services by type.

- **Hospital List & Details:**  
  - View a list of nearby hospitals with name, address, rating, and quick actions.
  - Detailed hospital pages show address, phone, website, rating, estimated distance, travel time, opening hours, and user reviews.
  - "Get Directions" button opens navigation in Google Maps.

- **User Reviews:**  
  - Users can read and submit reviews for hospitals.

- **Dark Mode:**  
  - Full support for light and dark themes, with a toggle available throughout the app.

- **Appointment Booking:**  
  - The appointment booking feature is retained and refactored to fit the new UI and data model.

### Technology Stack
- **Flutter** for cross-platform UI (web, Android, iOS)
- **Firebase** for authentication, data storage, and real-time updates
- **Google Maps API** (optional, for distance and directions features)

### What’s Removed
- All previous HelloDoc-specific branding and dashboard features not related to hospital search or appointment booking.
- Any unused or placeholder features from the old app.

---

## **How to Fix**

### 1. **Add the Required Packages**

Open your `pubspec.yaml` file (in `Signup_login/`) and add these dependencies under `dependencies:`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.0.0
  firebase_auth: ^4.0.0
  cloud_firestore: ^4.0.0
  google_sign_in: ^6.0.0
  url_launcher: ^6.0.0
```

> (You can use the latest compatible versions. If you already have some of these, just add the missing ones.)

---

### 2. **Install the Packages**

In your terminal (in the `Signup_login` directory), run:

```bash
flutter pub get
```

---

### 3. **Re-run Your App**

After the packages are installed, run:

```bash
flutter run -d chrome
```

---

### 4. **If You See Any Firebase Web Errors**

Make sure you have initialized Firebase for web. You may need to add a `firebase_options.dart` file (generated by the FlutterFire CLI) and initialize Firebase with it in your `main.dart`:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

---

## **Summary**

- Add the missing dependencies to `pubspec.yaml`
- Run `flutter pub get`
- Re-run your app

This will resolve the "not found" and "couldn't resolve the package" errors.

---

**Let me know if you need the exact `pubspec.yaml` content or step-by-step help editing it!**

---

## **How to Fix (Step-by-Step)**

### 1. **Open your `pubspec.yaml` file**  
This file is in your `Signup_login` directory.

### 2. **Add the required dependencies**  
Under the `dependencies:` section, add (or update) the following:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.0.0
  firebase_auth: ^4.0.0
  cloud_firestore: ^4.0.0
  google_sign_in: ^6.0.0
  url_launcher: ^6.0.0
```

> (If any of these are already present, just make sure the missing ones are added.)

---

### 3. **Install the packages**  
In your terminal, make sure you are in the `Signup_login` directory, then run:

```bash
flutter pub get
```

---

### 4. **Re-run your app**  
After the packages are installed, run:

```bash
flutter run -d chrome
```

---

### 5. **If you see Firebase web errors**  
You may need to initialize Firebase for web.  
If you haven’t already, use the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) to generate `firebase_options.dart` and update your `main.dart` as shown in the README.

---

## **Summary Table**

| Step                | Command / Action                        |
|---------------------|-----------------------------------------|
| Edit dependencies   | Edit `pubspec.yaml`                     |
| Install packages    | `
