const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const functions = require('firebase-functions');
const path = require('path');

const app = express();
const PORT = 3000;

// Initialize Firebase Admin SDK
const serviceAccount = require(path.join(__dirname, 'key/fitbattles-167ae-firebase-adminsdk-7sgte-118548e1c0.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

app.use(bodyParser.json());

// Route to send notifications
app.post('/sendNotification', (req, res) => {
  const message = {
    notification: {
      title: req.body.title,
      body: req.body.body,
    },
    data: {
      route: req.body.route,
    },
    token: req.body.token, // Firebase token to send the notification to
  };

  admin.messaging().send(message)
    .then((response) => {
      res.status(200).send(`Notification sent successfully: ${response}`);
    })
    .catch((error) => {
      res.status(500).send(`Error sending notification: ${error}`);
    });
});

// Route to sign up a new user and create a Firestore document
app.post('/signup', async (req, res) => {
  const { email, password } = req.body;

  try {
    // Create user in Firebase Authentication
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
    });

    // Create user document in Firestore
    const userDoc = {
      email: email,
      username: email.split('@')[0], // Default username from email
      profileImageUrl: '', // Default or empty profile image URL
      points: 0, // Initial points
      friends: [], // Initial friends array
      createdAt: new Date().toISOString(), // Timestamp
    };

    // Save user document to Firestore
    await admin.firestore().collection('users').doc(userRecord.uid).set(userDoc);

    res.status(201).send(`User created successfully: ${userRecord.uid}`);
  } catch (error) {
    res.status(500).send(`Error creating user: ${error}`);
  }
});

// Export the app as a Cloud Function
exports.api = functions.https.onRequest(app);
