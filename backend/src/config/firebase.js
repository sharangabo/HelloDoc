const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
let serviceAccount = null;

// Check if we have Firebase credentials
if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_PRIVATE_KEY) {
  serviceAccount = {
    type: 'service_account',
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
    private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    client_id: process.env.FIREBASE_CLIENT_ID,
    auth_uri: process.env.FIREBASE_AUTH_URI,
    token_uri: process.env.FIREBASE_TOKEN_URI,
    auth_provider_x509_cert_url: process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
    client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL
  };
}

// Initialize Firebase Admin if not already initialized
if (!admin.apps.length) {
  if (serviceAccount) {
    // Use service account credentials
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}.firebaseio.com`
    });
  } else {
    // Use default credentials for development
    console.log('⚠️  Using default Firebase credentials for development');
    admin.initializeApp();
  }
}

// Get Firestore instance
const db = admin.firestore();

// Get Auth instance
const auth = admin.auth();

// Collection references
const collections = {
  users: db.collection(`${process.env.FIRESTORE_COLLECTION_PREFIX || 'rwanda_health'}_users`),
  facilities: db.collection(`${process.env.FIRESTORE_COLLECTION_PREFIX || 'rwanda_health'}_facilities`),
  doctors: db.collection(`${process.env.FIRESTORE_COLLECTION_PREFIX || 'rwanda_health'}_doctors`),
  appointments: db.collection(`${process.env.FIRESTORE_COLLECTION_PREFIX || 'rwanda_health'}_appointments`),
  notifications: db.collection(`${process.env.FIRESTORE_COLLECTION_PREFIX || 'rwanda_health'}_notifications`),
  specialties: db.collection(`${process.env.FIRESTORE_COLLECTION_PREFIX || 'rwanda_health'}_specialties`),
  reviews: db.collection(`${process.env.FIRESTORE_COLLECTION_PREFIX || 'rwanda_health'}_reviews`)
};

module.exports = {
  admin,
  db,
  auth,
  collections
}; 