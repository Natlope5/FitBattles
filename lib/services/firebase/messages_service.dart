import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateChatId(String userId, String recipientId) {
    return (userId.compareTo(recipientId) < 0) ? '${userId}_$recipientId' : '${recipientId}_$userId';
  }

  Stream<QuerySnapshot> getMessages(String recipientId) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const Stream.empty();

    final chatId = _generateChatId(currentUser.uid, recipientId);
    return _firestore.collection('messages').doc(chatId).collection('chat').orderBy('timestamp').snapshots();
  }

  Future<void> sendMessage(String recipientId, String message) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final chatId = _generateChatId(currentUser.uid, recipientId);

    final messageData = {
      'senderId': currentUser.uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('messages').doc(chatId).collection('chat').add(messageData);
  }
}