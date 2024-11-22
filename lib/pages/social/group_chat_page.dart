import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({super.key});

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _groupChatId;

  Future<void> _createGroup() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) return;

    final groupDoc = await _firestore.collection('groupChats').add({
      'name': groupName,
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'members': [user.uid],
    });

    setState(() {
      _groupChatId = groupDoc.id;
    });

    _groupNameController.clear();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    final user = _auth.currentUser;

    if (message.isEmpty || user == null || _groupChatId == null) return;

    await _firestore
        .collection('groupChats')
        .doc(_groupChatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Stream<QuerySnapshot> _getMessages() {
    if (_groupChatId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('groupChats')
        .doc(_groupChatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupChatId == null ? 'Create Group Chat' : 'Group Chat'),
      ),
      body: Column(
        children: [
          if (_groupChatId == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _createGroup,
                    child: const Text('Create Group'),
                  ),
                ],
              ),
            ),
          if (_groupChatId != null)
            Expanded(
              child: StreamBuilder(
                stream: _getMessages(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No messages yet.'));
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender =
                          message['senderId'] == _auth.currentUser?.uid;

                      return Align(
                        alignment:
                        isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSender ? Colors.blue[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(message['message']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          if (_groupChatId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}