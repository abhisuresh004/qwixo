import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qwixo/auth.dart';
import 'package:qwixo/chat_services.dart';
import 'package:qwixo/firestore_services.dart';
import 'package:qwixo/localstorage.dart';
import 'package:qwixo/presence_manager.dart';
import 'package:qwixo/screens/chat.dart';
import 'package:qwixo/screens/login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showSearch = false;
  String _userName = '';
  String _userEmail = '';
  String _userPhoto = '';
  final chatservice _chatservice = chatservice();
  Map<String, Map<String, dynamic>> _usersCache = {};

  @override
  void initState() {
    super.initState();
    loadUserData();
    PresenceManager.setupPresence();
  }

  Future<void> loadUserData() async {
    final userData = await Localstorage.getuser();
    setState(() {
      _userName = userData['name'] ?? '';
      _userEmail = userData['email'] ?? '';
      _userPhoto = userData['photourl'] ?? '';
    });
  }

  String formatLastSeen(dynamic lastSeen) {
    if (lastSeen == null) return 'Last seen: unknown';

    DateTime lastSeenTime;
    if (lastSeen is DateTime) {
      lastSeenTime = lastSeen;
    } else if (lastSeen is int) {
      lastSeenTime = DateTime.fromMillisecondsSinceEpoch(lastSeen);
    } else if (lastSeen is Timestamp) {
      lastSeenTime = lastSeen.toDate();
    } else {
      return 'Last seen: unknown';
    }

    final diff = DateTime.now().difference(lastSeenTime);
    if (diff.inMinutes < 1) return 'Last seen: just now';
    if (diff.inMinutes < 60) return 'Last seen: ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Last seen: ${diff.inHours} hr ago';
    return 'Last seen: ${lastSeenTime.day}/${lastSeenTime.month}/${lastSeenTime.year}';
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirestoreServices().updateUserPresence(false);
              await Authservices().Signout();
              await Localstorage.cleardata();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showNewChatDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Start New Chat'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: 'Enter user email',border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              final userResult = await FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: email)
                  .get();

              if (userResult.docs.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('User not found')));
                return;
              }

              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                );
                return;
              }

              final otherUser = userResult.docs.first.data();
              final otherUserId = otherUser['uid'];
              final otherUserName = otherUser['name'];
              final otherUserPhoto = otherUser['photourl'];

              final chatId = chatservice().getchatid(
                currentUser.uid,
                otherUserId,
              );

              final chatDoc = FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId);
              final chatSnapshot = await chatDoc.get();

              if (!chatSnapshot.exists) {
                await chatDoc.set({
                  'participants': [currentUser.uid, otherUserId],
                  'lastMessage': '',
                  'timestamp': FieldValue.serverTimestamp(),
                });
              }

              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverName: otherUserName,
                    receiverid: otherUserId,
                    receiverPhoto: otherUserPhoto,
                  ),
                ),
              );
            },
            child: Text('Start'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    print('Current user: $currentUser');

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Please log in")));
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        hoverColor: Colors.deepPurple,
        child: Icon(Icons.chat_bubble),
        onPressed: () => showNewChatDialog(context),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels > 199 && !_showSearch) {
            setState(() {
              _showSearch = true;
            });
          } else if (scrollInfo.metrics.pixels <= 199 && _showSearch) {
            setState(() {
              _showSearch = false;
            });
          }
          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.deepPurple,
              pinned: true,
              floating: true,
              snap: true,
              centerTitle: true,
              stretch: true,
              expandedHeight: 200,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  return FlexibleSpaceBar(
                    title: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _userPhoto.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(_userPhoto),
                                  radius: 18,
                                )
                              : const CircleAvatar(
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                          const SizedBox(width: 10),
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () => showLogoutDialog(context),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showSearch
                    ? Padding(
                        key: ValueKey(true),
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey(false)),
              ),
            ),

            // 🔹 Chat List
            // 🔹 Chat List with preloaded user data
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('participants', arrayContains: currentUser.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No chats yet")),
                  );
                }

                final chats = snapshot.data!.docs;

                // Collect all other user IDs
                final otherUserIds = chats
                    .map((chat) {
                      final participants = List<String>.from(
                        chat['participants'],
                      );
                      return participants.firstWhere(
                        (id) => id != currentUser.uid,
                      );
                    })
                    .toSet()
                    .toList(); // remove duplicates

                // Preload uncached users
                final uncachedIds = otherUserIds
                    .where((id) => !_usersCache.containsKey(id))
                    .toList();
                if (uncachedIds.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .where(FieldPath.documentId, whereIn: uncachedIds)
                      .get()
                      .then((snapshot) {
                        for (var doc in snapshot.docs) {
                          _usersCache[doc.id] = doc.data()!;
                        }
                        setState(() {}); // refresh UI once users are cached
                      });
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final chat = chats[index];
                    final participants = List<String>.from(
                      chat['participants'],
                    );
                    final otherUserId = participants.firstWhere(
                      (id) => id != currentUser.uid,
                    );

                    final userData = _usersCache[otherUserId];
                    if (userData == null) {
                      // still loading
                      return const ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text("Loading..."),
                      );
                    }

                    final otherUserName = userData['name'];
                    final receiverPhoto = userData['photourl'];
                    final lastMessage = chat['lastMessage'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: receiverPhoto.isNotEmpty
                            ? NetworkImage(receiverPhoto)
                            : null,
                        child: receiverPhoto.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: Text(otherUserName),
                      subtitle: Text(lastMessage),
                      trailing: Column(
                        children: [
                          if (userData['isOnline'] == true)
                            Text(
                              'Online',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            )
                          else
                            Text(
                              formatLastSeen(userData['lastSeen']),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              receiverName: otherUserName,
                              receiverid: otherUserId,
                              receiverPhoto: receiverPhoto,
                            ),
                          ),
                        );
                      },
                    );
                  }, childCount: chats.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
