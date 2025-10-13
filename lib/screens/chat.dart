import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qwixo/chat_services.dart';

class ChatScreen extends StatefulWidget {
  final String receiverName;
  final String receiverid;
  final String receiverPhoto;

  const ChatScreen({
    super.key,
    required this.receiverName,
    required this.receiverid,
    required this.receiverPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final _chatservice =chatservice();
   final currentUser = FirebaseAuth.instance.currentUser!;

  //lastseen
  String formatLastSeen(dynamic lastSeen) {
  if (lastSeen == null) return 'Last seen: unknown';

  DateTime lastSeenTime;

  if (lastSeen is DateTime) {
    lastSeenTime = lastSeen;
  } else if (lastSeen is int) {
    lastSeenTime = DateTime.fromMillisecondsSinceEpoch(lastSeen);
  } else if (lastSeen is Timestamp) { // If using Firestore Timestamp
    lastSeenTime = lastSeen.toDate();
  } else {
    return 'Last seen: unknown';
  }

  final now = DateTime.now();
  final diff = now.difference(lastSeenTime);

  if (diff.inMinutes < 1) return 'Last seen: just now';
  if (diff.inMinutes < 60) return 'Last seen: ${diff.inMinutes} min ago';
  if (diff.inHours < 24) return 'Last seen: ${diff.inHours} hr ago';
  return 'Last seen: ${lastSeenTime.day}/${lastSeenTime.month}/${lastSeenTime.year}';
}



  // temporary list to simulate messages
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hey there!", "isMe": false},
    {"text": "Hi! How are you?", "isMe": true},
  ];

  void _sendMessage()async {
     final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await _chatservice.sendmessage(
      senderid: currentUser.uid,
      receiverid: widget.receiverid,
      message: text,
    );

    _messageController.clear();

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverPhoto),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatservice.getmessages(
                currentUser.uid,
                widget.receiverid,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final _messages = snapshot.data!.docs.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg['senderid'] == currentUser.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.deepPurple.shade400
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isMe
                                ? const Radius.circular(12)
                                : Radius.zero,
                            bottomRight: isMe
                                ? Radius.zero
                                : const Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input area
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.deepPurple,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
