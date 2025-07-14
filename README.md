# HelloDoc

A cross-platform Flutter application for booking medical appointments, with multi-language support and a modern, user-friendly interface.

---

## 📖 Description

**HelloDoc** is a mobile and web application that allows users to:
- Sign up and log in securely
- Book medical appointments
- View a dashboard with user information
- Switch between light and dark mode
- Use the app in English, French, or Kinyarwanda
- (Planned) Find hospitals, check doctor availability, and view wait times

The app is built with Flutter and Firebase, supporting Android, iOS, and web platforms.

---

## 🔗 GitHub Repository

[GitHub Repo Link](https://github.com/sharangabo/HelloDoc)


---

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

---

## 🎨 Designs

### Figma Mockups

- [Figma Design Link](https://www.figma.com/file/your-figma-link)
  *Replace with your actual Figma link.*

### Screenshots

| Login Screen | Home Dashboard | Appointment Booking |
|--------------|---------------|--------------------|
| ![Login]() | ![Home]() | ![Booking]() |

*Add your screenshots in a `screenshots/` folder and update the paths above.*

---

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

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
