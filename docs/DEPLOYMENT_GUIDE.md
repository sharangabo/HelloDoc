# HelloDoc - Deployment Guide

## Overview
This guide covers the deployment of both the Node.js backend API and Flutter mobile application for the HelloDoc project.

## Backend Deployment

### Option 1: Heroku Deployment

#### Prerequisites
- Heroku account
- Heroku CLI installed
- Git repository

#### Steps

1. **Install Heroku CLI**
```bash
# macOS
brew install heroku/brew/heroku

# Windows
# Download from https://devcenter.heroku.com/articles/heroku-cli
```

2. **Login to Heroku**
```bash
heroku login
```

3. **Create Heroku App**
```bash
cd backend
heroku create rwanda-health-connect-api
```

4. **Set Environment Variables**
```bash
heroku config:set NODE_ENV=production
heroku config:set PORT=3000
heroku config:set FIREBASE_PROJECT_ID=your-firebase-project-id
heroku config:set FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
heroku config:set FIREBASE_CLIENT_EMAIL=your-service-account-email
heroku config:set GOOGLE_MAPS_API_KEY=your-google-maps-api-key
heroku config:set JWT_SECRET=your-jwt-secret
```

5. **Deploy to Heroku**
```bash
git add .
git commit -m "Deploy to Heroku"
git push heroku main
```

6. **Verify Deployment**
```bash
heroku open
# Should show the API documentation
```

### Option 2: DigitalOcean App Platform

#### Prerequisites
- DigitalOcean account
- GitHub repository

#### Steps

1. **Create App in DigitalOcean**
   - Go to DigitalOcean App Platform
   - Connect your GitHub repository
   - Select the backend directory

2. **Configure Environment**
   - Set environment variables in DigitalOcean dashboard
   - Configure build settings

3. **Deploy**
   - DigitalOcean will automatically deploy on code changes

### Option 3: AWS EC2 Deployment

#### Prerequisites
- AWS account
- EC2 instance
- Domain name (optional)

#### Steps

1. **Launch EC2 Instance**
```bash
# Launch Ubuntu 20.04 LTS instance
# Configure security groups for ports 22, 80, 443, 3000
```

2. **Connect to Instance**
```bash
ssh -i your-key.pem ubuntu@your-instance-ip
```

3. **Install Node.js and PM2**
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2
sudo npm install -g pm2

# Install Nginx
sudo apt install nginx -y
```

4. **Clone and Setup Application**
```bash
# Clone repository
git clone https://github.com/your-username/rwanda-health-connect.git
cd rwanda-health-connect/backend

# Install dependencies
npm install

# Create environment file
cp env.example .env
# Edit .env with your configuration
```

5. **Configure PM2**
```bash
# Create PM2 ecosystem file
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [{
    name: 'rwanda-health-api',
    script: 'src/server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
}
EOF

# Start application
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

6. **Configure Nginx**
```bash
# Create Nginx configuration
sudo nano /etc/nginx/sites-available/rwanda-health-api

# Add configuration
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/rwanda-health-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

7. **Setup SSL with Let's Encrypt**
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Option 4: Docker Deployment

#### Prerequisites
- Docker installed
- Docker Compose installed

#### Steps

1. **Create Dockerfile**
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

2. **Create Docker Compose**
```yaml
version: '3.8'
services:
  api:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
      - FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}
      - FIREBASE_PRIVATE_KEY=${FIREBASE_PRIVATE_KEY}
      - FIREBASE_CLIENT_EMAIL=${FIREBASE_CLIENT_EMAIL}
      - GOOGLE_MAPS_API_KEY=${GOOGLE_MAPS_API_KEY}
      - JWT_SECRET=${JWT_SECRET}
    restart: unless-stopped
```

3. **Deploy with Docker**
```bash
docker-compose up -d
```

## Frontend Deployment

### Android App Store Deployment

#### Prerequisites
- Google Play Console account
- Keystore for signing
- App bundle

#### Steps

1. **Generate Keystore**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Configure Signing**
```bash
# Create key.properties in android/
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=upload
storeFile=<location of the key store file, e.g., /Users/<user name>/upload-keystore.jks>
```

3. **Update build.gradle**
```gradle
// android/app/build.gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

4. **Build App Bundle**
```bash
flutter build appbundle --release
```

5. **Upload to Google Play Console**
   - Go to Google Play Console
   - Create new app
   - Upload app bundle
   - Configure store listing
   - Submit for review

### iOS App Store Deployment

#### Prerequisites
- Apple Developer account
- Xcode
- App Store Connect access

#### Steps

1. **Configure iOS Settings**
```bash
# Update ios/Runner/Info.plist
# Add required permissions and descriptions
```

2. **Build iOS App**
```bash
flutter build ios --release
```

3. **Archive in Xcode**
   - Open ios/Runner.xcworkspace in Xcode
   - Select Product > Archive
   - Upload to App Store Connect

4. **Submit for Review**
   - Go to App Store Connect
   - Configure app information
   - Submit for review

### Firebase App Distribution (Beta Testing)

#### Prerequisites
- Firebase project
- Test devices

#### Steps

1. **Configure Firebase App Distribution**
```bash
# Add to pubspec.yaml
dev_dependencies:
  firebase_app_distribution: ^0.2.0+1
```

2. **Build and Distribute**
```bash
# Android
flutter build apk --release
firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-release.apk" \
  --app 1:123456789:android:abcdef \
  --groups "testers" \
  --release-notes "Bug fixes and improvements"

# iOS
flutter build ios --release
firebase appdistribution:distribute "build/ios/iphoneos/Runner.app" \
  --app 1:123456789:ios:abcdef \
  --groups "testers" \
  --release-notes "Bug fixes and improvements"
```

## Environment Configuration

### Production Environment Variables

#### Backend (.env)
```env
NODE_ENV=production
PORT=3000
FIREBASE_PROJECT_ID=rwanda-health-connect
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@rwanda-health-connect.iam.gserviceaccount.com
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
JWT_SECRET=your-super-secret-jwt-key
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
FIRESTORE_COLLECTION_PREFIX=rwanda_health
LOG_LEVEL=info
ALLOWED_ORIGINS=https://your-domain.com,https://app.your-domain.com
```

#### Frontend (lib/core/config/env.dart)
```dart
class Env {
  static const String apiBaseUrl = 'https://your-api-domain.com/api';
  static const String firebaseProjectId = 'rwanda-health-connect';
  static const String googleMapsApiKey = 'your-google-maps-api-key';
}
```

## Monitoring and Logging

### Application Monitoring

#### 1. Firebase Performance Monitoring
```dart
// Add to main.dart
import 'package:firebase_performance/firebase_performance.dart';

// Initialize
await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
```

#### 2. Firebase Crashlytics
```dart
// Add to main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Initialize
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
```

#### 3. Backend Logging
```javascript
// Add to server.js
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

### Health Checks

#### Backend Health Check
```bash
curl https://your-api-domain.com/health
```

Expected response:
```json
{
  "status": "OK",
  "timestamp": "2024-01-10T10:30:00.000Z",
  "environment": "production",
  "version": "1.0.0"
}
```

## Security Considerations

### 1. API Security
- Use HTTPS for all communications
- Implement rate limiting
- Validate all inputs
- Use environment variables for secrets

### 2. Firebase Security Rules
```javascript
// Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /rwanda_health_users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /rwanda_health_facilities/{facilityId} {
      allow read: if true;
      allow write: if request.auth != null && get(/databases/$(database)/documents/rwanda_health_users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 3. App Security
- Implement certificate pinning
- Use secure storage for sensitive data
- Implement proper authentication flow

## Backup and Recovery

### Database Backup
```bash
# Firebase Firestore backup
gcloud firestore export gs://your-backup-bucket/firestore-backup
```

### Application Backup
```bash
# Backup application files
tar -czf app-backup-$(date +%Y%m%d).tar.gz /path/to/app
```

## Scaling Considerations

### 1. Load Balancing
- Use multiple instances behind a load balancer
- Implement health checks
- Use auto-scaling groups

### 2. Database Scaling
- Use Firebase Firestore for automatic scaling
- Implement proper indexing
- Monitor query performance

### 3. CDN Configuration
- Use CDN for static assets
- Implement caching strategies
- Monitor CDN performance

## Maintenance

### Regular Tasks
1. **Security Updates**
   - Update dependencies regularly
   - Monitor security advisories
   - Apply patches promptly

2. **Performance Monitoring**
   - Monitor API response times
   - Track error rates
   - Optimize database queries

3. **Backup Verification**
   - Test backup restoration
   - Verify data integrity
   - Update backup procedures

### Update Procedures
1. **Backend Updates**
```bash
# Pull latest changes
git pull origin main

# Install dependencies
npm install

# Restart application
pm2 restart rwanda-health-api
```

2. **Frontend Updates**
   - Build new app bundle/archive
   - Submit to app stores
   - Monitor rollout

## Troubleshooting

### Common Issues

#### 1. API Not Responding
```bash
# Check application status
pm2 status
pm2 logs rwanda-health-api

# Check system resources
htop
df -h
```

#### 2. Database Connection Issues
```bash
# Verify Firebase configuration
firebase projects:list
firebase use your-project-id
```

#### 3. SSL Certificate Issues
```bash
# Check certificate status
sudo certbot certificates

# Renew if needed
sudo certbot renew
```

#### 4. App Store Rejection
- Review Apple/Google guidelines
- Fix identified issues
- Resubmit with explanations

## Support and Resources

### Documentation
- [Flutter Deployment](https://flutter.dev/docs/deployment)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Heroku Deployment](https://devcenter.heroku.com/articles/getting-started-with-nodejs)

### Monitoring Tools
- [Firebase Console](https://console.firebase.google.com/)
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com/)

### Community Support
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [GitHub Issues](https://github.com/flutter/flutter/issues) 