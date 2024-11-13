const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const path = require('path');

const app = express();
const PORT = 3000;

// Initialize Firebase Admin SDK
const serviceAccount = require(path.join(__dirname, 'android/app/key/fitbattles-167ae-firebase-adminsdk-7sgte-118548e1c0.json'));

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
      fcmToken: '', // Placeholder for the user's FCM token
    };

    // Save user document to Firestore
    await admin.firestore().collection('users').doc(userRecord.uid).set(userDoc);

    res.status(201).send(`User created successfully: ${userRecord.uid}`);
  } catch (error) {
    res.status(500).send(`Error creating user: ${error}`);
  }
});

// Route to update user's FCM token
app.post('/updateFcmToken', async (req, res) => {
  const { userId, fcmToken } = req.body;

  try {
    // Update the user's FCM token in Firestore
    await admin.firestore().collection('users').doc(userId).update({ fcmToken });
    res.status(200).send('FCM token updated successfully');
  } catch (error) {
    res.status(500).send(`Error updating FCM token: ${error}`);
  }
});

// Route to award badges and send notifications
app.post('/awardBadge', async (req, res) => {
  const { userId, badgeName } = req.body;

  try {
    // Logic to award badge (e.g., save to Firestore)
    await admin.firestore().collection('userBadges').add({
      userId: userId,
      badgeName: badgeName,
      earnedAt: new Date().toISOString(),
    });

    // Retrieve user's FCM token
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const fcmToken = userDoc.data().fcmToken;

    // Send notification to the user
    if (fcmToken) {
      const message = {
        notification: {
          title: 'Congratulations!',
          body: `You earned the ${badgeName} badge!`,
        },
        data: {
          route: '/badges', // Route to navigate on click
        },
        token: fcmToken,
      };

      await admin.messaging().send(message);
    }

    res.status(200).send('Badge awarded and notification sent');
  } catch (error) {
    res.status(500).send(`Error awarding badge: ${error}`);
  }
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
