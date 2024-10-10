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

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
