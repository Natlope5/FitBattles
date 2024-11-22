import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate the conversation document path
  String _getConversationPath(String userId, String otherUserId) {
    return 'users/$userId/conversations/$otherUserId/messages';
  }

  // Fetch messages between the current user and a specific friend
  Stream<QuerySnapshot> getMessages(String friendId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    final path = _getConversationPath(currentUser.uid, friendId);
    return _firestore.collection(path).orderBy('timestamp').snapshots();
  }

  // Send a message to a specific friend
  Future<void> sendMessage(String friendId, String message) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final messageData = {
      'senderId': currentUser.uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add the message to the sender's conversation
    await _firestore
        .collection(_getConversationPath(currentUser.uid, friendId))
        .add(messageData);

    // Add the message to the recipient's conversation
    await _firestore
        .collection(_getConversationPath(friendId, currentUser.uid))
        .add(messageData);

    // Update the last message and timestamp in the conversation metadata
    final updateData = {
      'lastMessage': message,
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    await _firestore
        .doc('users/${currentUser.uid}/conversations/$friendId')
        .set(updateData, SetOptions(merge: true));

    await _firestore
        .doc('users/$friendId/conversations/${currentUser.uid}')
        .set(updateData, SetOptions(merge: true));
  }

  // Fetch conversations for the current user
  Stream<QuerySnapshot> getConversations() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('users/${currentUser.uid}/conversations')
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  // Mark a conversation as read
  Future<void> markAsRead(String conversationId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _firestore
        .doc('users/${currentUser.uid}/conversations/$conversationId')
        .update({
      'lastRead': FieldValue.serverTimestamp(),
    });
  }

  // Toggle mute status for a conversation
  Future<void> toggleMute(String conversationId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final docRef =
    _firestore.doc('users/${currentUser.uid}/conversations/$conversationId');

    final doc = await docRef.get();
    final isMuted = doc.exists && (doc.data()?['muted'] == true);

    await docRef.update({'muted': !isMuted});
  }

  // Check if a conversation is muted
  Future<bool> isMuted(String conversationId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final doc = await _firestore
        .doc('users/${currentUser.uid}/conversations/$conversationId')
        .get();

    return doc.exists && (doc.data()?['muted'] == true);
  }

  // Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _firestore
        .collection('users/${currentUser.uid}/conversations')
        .doc(conversationId)
        .delete();
  }
}