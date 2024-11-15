import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetcake/user_service/friendship_service.dart';

class FriendAddPage extends StatefulWidget {
  const FriendAddPage({super.key});

  @override
  State<FriendAddPage> createState() => _FriendAddPageState();
}

class _FriendAddPageState extends State<FriendAddPage> {
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
        future: friendshipService.fetchPotentialFriends(userId!).whenComplete(
            () => setState(() {})), // Using the filtered friends method
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
      leading: FutureBuilder<String?>(
        future: friendshipService.fetchUserImageUrl(
            username), // Асинхронно получаем ссылку на изображение
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CircleAvatar(
              backgroundImage: NetworkImage(snapshot.data!),
            );
          } else {
            return CircleAvatar(
                child: Icon(Icons.person)); // Стандартный аватар
          }
        },
      ),
      title: Text(username),
      trailing: IconButton(
        icon: Icon(Icons.person_add, color: Colors.blue),
        onPressed: () async {
          await friendshipService
              .sendFriendRequest(this.userId!, userId)
              .whenComplete(() => setState(() {}));
        },
      ),
    );
  }
}
