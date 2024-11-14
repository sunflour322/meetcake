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

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final FriendshipService friendshipService = FriendshipService();
  final UserCRUD userCRUD = UserCRUD();
  String? userId;
  var username, email;
  String? profileImageUrl;
  int friendsCount = 0;

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
        });
      });
      _fetchFriendsCount();
    }
  }

  Future<void> _fetchFriendsCount() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      friendsCount = (userDoc['friends'] as List).length;
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
        widthFactor: 0.95, // почти на всю высоту экрана
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
                        MaterialPageRoute(builder: (context) => UserListPage()),
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
    );
  }

  void _onAvatarTap() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final drive.File uploadedImage = await _uploadImageToGoogleDrive(image);
      final String downloadUrl = uploadedImage.webViewLink!;
      _saveImageUrlToFirestore(downloadUrl);
    }
  }

// Функция загрузки фото в Google Drive
  Future<drive.File> _uploadImageToGoogleDrive(XFile image) async {
    final driveApi = drive.DriveApi(http.Client());
    final drive.File fileToUpload = drive.File();
    fileToUpload.name = image.name;
    fileToUpload.mimeType = 'image/jpeg';

    final response = await driveApi.files.create(
      fileToUpload,
      uploadMedia:
          drive.Media(image.readAsBytes().asStream(), image.length as int?),
    );
    return response;
  }

// Функция сохранения URL в Firestore
  void _saveImageUrlToFirestore(String url) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profileImageUrl': url,
    });
    setState(() {
      profileImageUrl = url;
    });
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
                  onTap: () {
                    _onAvatarTap();
                  },
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
                  'Имя: $username',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Email: $email',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          Color.fromRGBO(148, 185, 255, 1))),
                  onPressed: () {
                    _showFriendsBottomSheet(context);
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
        backgroundColor: Color.fromRGBO(148, 185, 255, 1),
        child: Icon(Icons.arrow_back_ios_sharp),
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
                        .whenComplete(() => setState(() {}));
                    ;
                    await _fetchFriendsCount()
                        .whenComplete(() => setState(() {}));
                    ;
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
                          .whenComplete(() => setState(() {}));
                      ;
                      await _fetchFriendsCount()
                          .whenComplete(() => setState(() {}));
                      ;
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () async {
                    friendId = await userCRUD
                        .fetchUserID(friendName)
                        .whenComplete(() => setState(() {}));
                    ;
                    await friendshipService
                        .rejectFriendRequest(userId!, friendId)
                        .whenComplete(() => setState(() {}));
                    ;
                  },
                ),
              ],
            ),
    );
  }
}
