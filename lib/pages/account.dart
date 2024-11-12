import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetcake/pages/friend_add.dart';
import 'package:meetcake/user_service/friendship_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final FriendshipService friendshipService = FriendshipService();
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid; // Получаем текущий userId
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Друзья'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserListPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<dynamic> friends = snapshot.data!['friends'] ?? [];
                List<dynamic> friendRequests =
                    snapshot.data!['friendRequests'] ?? [];

                return ListView(
                  children: [
                    _buildSectionTitle('Ваши друзья'),
                    ...friends
                        .map((friendId) => _buildFriendTile(friendId, true))
                        .toList(),
                    _buildSectionTitle('Запросы на дружбу'),
                    ...friendRequests
                        .map((requesterId) =>
                            _buildFriendTile(requesterId, false))
                        .toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFriendTile(String friendId, bool isFriend) {
    return ListTile(
      title: Text(friendId),
      trailing: isFriend
          ? IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () =>
                  friendshipService.removeFriend(userId!, friendId),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () =>
                      friendshipService.acceptFriendRequest(userId!, friendId),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () =>
                      friendshipService.rejectFriendRequest(userId!, friendId),
                ),
              ],
            ),
    );
  }
}
