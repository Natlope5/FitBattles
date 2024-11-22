import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitbattles/pages/social/messages_page.dart';
import 'package:fitbattles/services/firebase/messages_service.dart';
import 'package:fitbattles/services/firebase/friends_service.dart';

class ConversationsListPage extends StatefulWidget {
  const ConversationsListPage({super.key});

  @override
  State<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends State<ConversationsListPage> {
  final MessagesService _messagesService = MessagesService();
  final FriendsService _friendsService = FriendsService();

  Future<String> _getDisplayName(String userId) async {
    // Check the friends list first
    final friend = await _friendsService.fetchFriendById(userId);
    if (friend != null && friend['name'] != null) {
      return friend['name'];
    }

    // Fallback to settings/profile/name
    final settingsDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('profile')
        .get();

    if (settingsDoc.exists && settingsDoc.data()?['name'] != null) {
      return settingsDoc.data()!['name'];
    }

    return 'Unknown User'; // Default if no name is found
  }

  void _showContextMenu(BuildContext context, String conversationId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mark_chat_read),
              title: const Text("Mark as read"),
              onTap: () {
                _messagesService.markAsRead(conversationId);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off),
              title: const Text("Mute"),
              onTap: () {
                // Handle muting the conversation
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text("Archive"),
              onTap: () {
                // Handle archiving the conversation
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () {
                _messagesService.deleteConversation(conversationId);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _messagesService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No conversations yet."));
          }

          final conversations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherUserId = conversation.id; // Assuming the conversation ID is the other user's ID
              final lastMessage = conversation['lastMessage'] ?? "";
              final lastUpdated = conversation['lastUpdated'] as Timestamp?;
              final conversationData = conversation.data() as Map<String, dynamic>?;

              // Safely handle `lastRead` field
              final lastRead = conversationData != null && conversationData.containsKey('lastRead')
                  ? conversationData['lastRead'] as Timestamp?
                  : null;

              // Determine if the conversation is unread
              final isUnread = lastRead == null || (lastUpdated != null && lastRead.compareTo(lastUpdated) < 0);

              return FutureBuilder<String>(
                future: _getDisplayName(otherUserId),
                builder: (context, snapshot) {
                  final displayName =
                  snapshot.hasData ? snapshot.data! : "Loading...";

                  return GestureDetector(
                    onLongPress: () => _showContextMenu(context, conversation.id),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person),
                      ),
                      title: Text(displayName),
                      subtitle: Text(lastMessage),
                      trailing: isUnread
                          ? const CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red,
                      )
                          : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagesPage(
                              friendId: otherUserId,
                              friendName: displayName,
                            ),
                          ),
                        );
                        // Mark conversation as read when opened
                        _messagesService.markAsRead(otherUserId);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}