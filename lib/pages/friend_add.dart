import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetcake/user_service/friendship_service.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final FriendshipService friendshipService = FriendshipService();
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить друзей'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: friendshipService.fetchPotentialFriends(
            userId!), // Using the filtered friends method
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> potentialFriends = snapshot.data!;

          return ListView(
            children:
                potentialFriends.map((user) => _buildUserTile(user)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    String userId = user['id'];
    String username = user['username'];

    return ListTile(
      title: Text(username),
      trailing: IconButton(
        icon: Icon(Icons.person_add, color: Colors.blue),
        onPressed: () =>
            friendshipService.sendFriendRequest(this.userId!, userId),
      ),
    );
  }
}
