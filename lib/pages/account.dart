import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetcake/database/collections/user_collection.dart';
import 'package:meetcake/pages/friend_add.dart';
import 'package:meetcake/pages/meets.dart';
import 'package:meetcake/user_service/friendship_service.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FriendshipService friendshipService = FriendshipService();
  final UserCRUD userCRUD = UserCRUD();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  var username, email;
  String? profileImageUrl;
  int friendsCount = 0;
  List categoriesCount = [];
  List<String> allCategories = [
    'Спорт',
    'Кино',
    'Музыка',
    'Чтение',
    'Природа',
    'Путешествия',
    'Танцы',
    'Готовка'
  ];
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      userCRUD.fetchUser().then((value) {
        setState(() {
          username = value?['username'];
          email = value?['email'];
          profileImageUrl = value?['profileImageUrl'];
          selectedCategories = List<String>.from(value?['categories'] ?? []);
        });
      });
      _fetchFriendsCount();
      _loadUserProfile();
      fetchCategories();
    }
  }

  Future<void> _loadUserProfile() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    setState(() {
      profileImageUrl = userDoc['profileImageUrl'];
      selectedCategories = List<String>.from(userDoc['categories'] ?? []);
    });
  }

  Future<void> _fetchFriendsCount() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      friendsCount = (userDoc['friends'] as List).length;
    });
  }

  Future<void> _uploadImageToFirebase() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    try {
      String userId = _auth.currentUser!.uid;
      String fileName = 'user_images/$userId/${DateTime.now()}.png';

      final ref = _storage.ref().child(fileName);
      await ref.putFile(File(image.path));

      final imageUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': imageUrl,
      });

      setState(() {
        profileImageUrl = imageUrl;
      });

      print("Image uploaded and link saved in Firestore.");
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _saveCategories() async {
    String userId = _auth.currentUser!.uid;

    await _firestore.collection('users').doc(userId).update({
      'categories': selectedCategories,
    });

    print("Categories updated in Firestore.");
  }

  Future<void> fetchCategories() async {
    String userId = _auth.currentUser!.uid;

    DocumentSnapshot categories =
        await _firestore.collection('users').doc(userId).get();
    print("Categories updated in Firestore.");
    categoriesCount = categories['categories'];
  }

  void _showCategoriesDialog(BuildContext context) {
    // Локальная копия выбранных категорий для управления состоянием
    List<String> tempSelectedCategories = List.from(selectedCategories);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Выберите категории досуга'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: allCategories.map((category) {
                    return CheckboxListTile(
                      title: Text(category),
                      value: tempSelectedCategories.contains(category),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value != null) {
                            if (value) {
                              if (!tempSelectedCategories.contains(category)) {
                                tempSelectedCategories.add(category);
                              }
                            } else {
                              tempSelectedCategories.remove(category);
                            }
                          }
                        });

                        // Обновляем сразу в Firestore и в локальном состоянии
                        setState(() {
                          selectedCategories =
                              List.from(tempSelectedCategories);
                        });

                        _saveCategories();
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Закрыть'),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() async {
      // Обновление списка категорий после закрытия диалога
      await fetchCategories();
      setState(() {});
    });
  }

  void _showFriendsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.5,
        widthFactor: 0.95,
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

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromRGBO(148, 185, 255, 1))),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FriendAddPage()),
                      );
                    },
                    child: Text("Добавить друзей"),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Ваши друзья'),
                          ...friends
                              .map((friendName) =>
                                  _buildFriendTile(friendName, true))
                              .toList(),
                          _buildSectionTitle('Запросы на дружбу'),
                          ...friendRequests
                              .map((friendName) =>
                                  _buildFriendTile(friendName, false))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ).whenComplete(() => _fetchFriendsCount());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: [
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _uploadImageToFirebase, // Open gallery on tap
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? Icon(Icons.add, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$username',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '$email',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromRGBO(148, 185, 255, 1))),
                  onPressed: () async {
                    _showCategoriesDialog(context);
                    await _fetchFriendsCount();
                  },
                  child: Text(
                    'Categories: ${categoriesCount.length}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Color.fromRGBO(148, 185, 255, 1))),
                  onPressed: () async {
                    _showFriendsBottomSheet(context);
                    await fetchCategories();
                  },
                  child: Text(
                    'Friends: $friendsCount',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MeetPage()));
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.arrow_back),
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

  Widget _buildFriendTile(String friendName, bool isFriend) {
    dynamic friendId;

    return ListTile(
        leading: FutureBuilder<String?>(
          future: friendshipService.fetchUserImageUrl(friendName),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CircleAvatar(
                backgroundImage: NetworkImage(snapshot.data!),
              );
            } else {
              return CircleAvatar(child: Icon(Icons.person)); // Если нет данных
            }
          },
        ),
        title: Text(friendName),
        trailing: isFriend
            ? IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () async {
                  if (username != null) {
                    friendId = await userCRUD
                        .fetchUserID(friendName)
                        .whenComplete(() => setState(() {}));
                    if (friendId != null) {
                      await friendshipService
                          .removeFriend(userId!, username!, friendId)
                          .whenComplete(() => _fetchFriendsCount());
                    }
                  }
                },
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      friendId = await userCRUD.fetchUserID(friendName);
                      if (friendId != null) {
                        await friendshipService
                            .acceptFriendRequest(userId!, friendId)
                            .whenComplete(() => _fetchFriendsCount());
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      friendId = await userCRUD
                          .fetchUserID(friendName)
                          .whenComplete(() => _fetchFriendsCount());
                      await friendshipService
                          .rejectFriendRequest(userId!, friendId)
                          .whenComplete(() => _fetchFriendsCount());
                    },
                  ),
                ],
              ));
  }
}
