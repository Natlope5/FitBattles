import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FriendsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  FriendsService() {
    _initializeLocalNotifications();
  }

  // Initializes local notifications
  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    _localNotificationsPlugin.initialize(initializationSettings);
  }

  // Ensures the current user has a unique friend code.
  Future<String?> ensureFriendCode() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

    if (userDoc.exists && userDoc.data()?['friendCode'] != null) {
      return userDoc['friendCode'];
    }

    // Generate and assign a unique friend code.
    String newFriendCode;
    do {
      newFriendCode = _generateRandomCode(6);
    } while (await _isFriendCodeInUse(newFriendCode));

    await _firestore.collection('users').doc(currentUser.uid).set(
      {'friendCode': newFriendCode},
      SetOptions(merge: true),
    );

    return newFriendCode;
  }

  // Generates a random alphanumeric code.
  String _generateRandomCode(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (_) => characters[_randomIndex(characters.length)])
        .join();
  }

  // Returns a random index for character generation.
  int _randomIndex(int max) => DateTime.now().millisecondsSinceEpoch % max;

  // Checks if a friend code is already in use.
  Future<bool> _isFriendCodeInUse(String code) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('friendCode', isEqualTo: code)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Fetches the current user's friends.
  Future<List<Map<String, dynamic>>> fetchFriends() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Fetches the current user's friend requests.
  Future<List<Map<String, dynamic>>> fetchFriendRequests() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friendRequests')
        .get();

    return snapshot.docs.map((doc) => {
      'name': doc['name'],
      'email': doc['email'],
      'status': doc['status'],
      'requestId': doc.id,
    }).toList();
  }

  // Sends a friend request by email or friend code.
  Future<Map<String, dynamic>?> sendFriendRequest({
    String? email,
    String? friendCode,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    QuerySnapshot userSnapshot;

    if (email != null) {
      userSnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
    } else if (friendCode != null) {
      userSnapshot = await _firestore
          .collection('users')
          .where('friendCode', isEqualTo: friendCode)
          .get();
    } else {
      return null;
    }

    if (userSnapshot.docs.isNotEmpty) {
      final friendId = userSnapshot.docs[0].id;

      await _firestore.collection('users').doc(friendId).collection('friendRequests').add({
        'name': (await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get()).data()?['name'] ?? 'Unknown',
        'email': currentUser.email,
        'status': 'pending',
      });
      return userSnapshot.docs[0].data() as Map<String, dynamic>;
    }
    return null;
  }

  // Accepts a friend request.
  Future<void> acceptFriendRequest(String requestId, String email) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final friendId = snapshot.docs[0].id;
      final friendData = snapshot.docs[0].data();

      // Add the friend to the current user's friend list.
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .doc(friendId)
          .set({
        'name': friendData['name'],
        'email': friendData['email'],
      });

      // Add the current user to the friend's friend list.
      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('friends')
          .doc(currentUser.uid)
          .set({
        'name': currentUser.displayName,
        'email': currentUser.email,
      });

      // Update the friend request status to accepted.
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friendRequests')
          .doc(requestId)
          .update({'status': 'accepted'});
    }
  }

  // Declines a friend request.
  Future<void> declineFriendRequest(String requestId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friendRequests')
        .doc(requestId)
        .delete();
  }

  // Schedules a local notification.
  Future<void> scheduleNotification(String title, String body) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'friend_requests_channel',
      'Friend Requests',
      importance: Importance.high,
      priority: Priority.high,
    );
    const platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}