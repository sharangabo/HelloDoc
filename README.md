# HelloDoc - Mobile Health Application

## Project Overview
A mobile health application that connects patients with nearby healthcare facilities and provides real-time doctor availability information. The goal is to reduce patient waiting times and improve healthcare accessibility.

## Core Features
- **GPS-powered facility finder**: Locate nearby hospitals and clinics within a 10km radius
- **Real-time doctor availability**: Live updates on which doctors are available for consultations
- **Appointment booking system**: Schedule, reschedule, or cancel appointments directly through the app
- **Navigation integration**: Turn-by-turn directions to selected healthcare facilities
- **Multi-language support**: Interface in multiple languages

## Technical Stack
- **Frontend**: Flutter framework for cross-platform mobile development (iOS and Android)
- **Backend**: Node.js with Express.js for server-side logic
- **Database**: Cloud Firestore for real-time data synchronization
- **Authentication**: Firebase Authentication for secure user management
- **Maps**: Google Maps API for location services and navigation

## Project Structure
```
hellodoc/
├── frontend/                 # Flutter mobile application
├── backend/                  # Node.js Express server
├── docs/                     # Documentation
└── README.md                 # This file
```

## Development Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Node.js (v18 or higher)
- Firebase CLI
- Google Cloud Platform account
- Android Studio / Xcode for mobile development

### Backend Setup
1. Navigate to the backend directory: `cd backend`
2. Install dependencies: `npm install`
3. Set up environment variables (see `.env.example`)
4. Start development server: `npm run dev`

### Frontend Setup
1. Navigate to the frontend directory: `cd frontend`
2. Install Flutter dependencies: `flutter pub get`
3. Configure Firebase (see frontend/README.md)
4. Run the app: `flutter run`

## Development Approach
- **Agile methodology** with 2-week sprints
- **Initial deployment** with 3-5 healthcare facilities
- **Scalability** designed to handle 500 concurrent users initially, expanding to 10,000+ users

## Contributing
Please read the contributing guidelines in the `docs/` directory before submitting pull requests.

## License
This project is licensed under the MIT License - see the LICENSE file for details. 