import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/pages/account.dart';
import 'package:meetcake/theme_lng/change_theme.dart';
import 'package:meetcake/user_service/friendship_service.dart';
import 'package:provider/provider.dart';

class FriendAddPage extends StatefulWidget {
  const FriendAddPage({super.key});

  @override
  State<FriendAddPage> createState() => _FriendAddPageState();
}

class _FriendAddPageState extends State<FriendAddPage> {
  final FriendshipService friendshipService = FriendshipService();
  String? userId;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allPotentialFriends = [];
  List<Map<String, dynamic>> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    _fetchPotentialFriends();
  }

  // Функция для получения списка потенциальных друзей
  Future<void> _fetchPotentialFriends() async {
    List<Map<String, dynamic>> friends =
        await friendshipService.fetchPotentialFriends(userId!);
    setState(() {
      allPotentialFriends = friends;
      filteredFriends = friends;
    });
  }

  // Фильтрация списка друзей по введенному запросу
  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredFriends = allPotentialFriends;
      } else {
        filteredFriends = allPotentialFriends
            .where((user) =>
                user['username'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: themeProvider.theme.primaryColorLight
                          .withOpacity(0.3),
                      border: Border.all(
                          width: 3,
                          color: Colors.white,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      style: TextStyle(fontSize: 20),
                      controller: searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: S.of(context).search,
                        hintStyle: TextStyle(fontSize: 20),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: _filterUsers,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: filteredFriends
                    .map((user) => _buildUserTile(user))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AccountPage()));
        },
        child: Icon(Icons.arrow_back),
        backgroundColor: Colors.orangeAccent,
      ),
    );
  }

  // Виджет для отображения каждого пользователя в списке
  Widget _buildUserTile(Map<String, dynamic> user) {
    String userId = user['id'];
    String username = user['username'];

    return ListTile(
      leading: FutureBuilder<String?>(
        // Загружаем изображение пользователя
        future: friendshipService.fetchUserImageUrl(username),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CircleAvatar(
              backgroundImage: NetworkImage(snapshot.data!),
            );
          } else {
            return CircleAvatar(child: Icon(Icons.person));
          }
        },
      ),
      title: Text(username),
      trailing: IconButton(
        icon: Icon(Icons.person_add, color: Colors.blue),
        onPressed: () async {
          // Отправляем запрос на дружбу
          await friendshipService
              .sendFriendRequest(this.userId!, userId)
              .whenComplete(() {
            // Убираем пользователя из списка после отправки запроса
            setState(() {
              allPotentialFriends
                  .removeWhere((friend) => friend['id'] == userId);
              filteredFriends.removeWhere((friend) => friend['id'] == userId);
            });
          });
        },
      ),
    );
  }
}
