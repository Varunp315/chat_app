import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (ctx, chatSnapsshot) {
        if (chatSnapsshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!chatSnapsshot.hasData || chatSnapsshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages yet!'));
        }

        if (chatSnapsshot.hasError) {
          return Center(child: Text('Error: ${chatSnapsshot.error}'));
        }

        final loadedMessages = chatSnapsshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          physics: const BouncingScrollPhysics(),
          itemCount: chatSnapsshot.data!.docs.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage =
                index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;

            final currentMessageUserID = chatMessage['userId'];
            final nextMessageUserID =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame = nextMessageUserID == currentMessageUserID;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser!.uid == currentMessageUserID,
              );
            } else {
              return MessageBubble.first(
                message: chatMessage['text'],
                isMe: authenticatedUser!.uid == currentMessageUserID,
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
              );
            }
          },
        );
      },
    );
  }
}
