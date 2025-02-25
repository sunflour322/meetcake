import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetcake/database/collections/meets_collection.dart';
import 'package:meetcake/database/collections/user_collection.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/pages/account.dart';
import 'package:meetcake/pages/catalog.dart';
import 'package:meetcake/pages/meet_profile.dart';
import 'package:meetcake/user_service/user_service.dart';

class MeetPage extends StatefulWidget {
  const MeetPage({super.key});

  @override
  State<MeetPage> createState() => _MeetPageState();
}

class _MeetPageState extends State<MeetPage> {
  AuthService _authService = AuthService();
  MeetsCRUD _meetsCRUD = MeetsCRUD();
  UserCRUD _userCRUD = UserCRUD();
  String? userId;
  String? username;
  final CollectionReference meetsCollection =
      FirebaseFirestore.instance.collection('meets');
  List<DocumentSnapshot> meetsList = [];
  List<DocumentSnapshot> userMeets = [];
  List<DocumentSnapshot> requestMeets = [];
  List<DocumentSnapshot> pastMeets = [];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _userCRUD.fetchUser().then((value) {
        setState(() {
          username = value?['username'];
        });
      });
    }
    _loadMeets();
  }

  // Загружаем все встречи
  _loadMeets() async {
    final snapshot = await meetsCollection.get();
    meetsList = snapshot.docs;

    setState(() {
      userMeets.clear();
      requestMeets.clear();
      pastMeets.clear();
    });

    // Фильтруем встречи по трем категориям
    for (var meetDoc in meetsList) {
      Map<String, dynamic> meetData = meetDoc.data() as Map<String, dynamic>;

      // Проверяем, есть ли пользователь в users
      if (meetData['users'].contains(username)) {
        userMeets.add(meetDoc);
      }

      // Проверяем, есть ли пользователь в requestUsers
      if (meetData['requestUsers'].contains(username)) {
        requestMeets.add(meetDoc);
      }

      // Проверяем, прошла ли встреча, и если да - добавляем в историю
      DateTime meetDate;

      if (meetData['datetime'] is Timestamp) {
        meetDate = (meetData['datetime'] as Timestamp).toDate();
      } else if (meetData['datetime'] is String) {
        if (meetData['datetime'] != '') {
          meetDate = DateTime.parse(meetData['datetime']);
        } else {
          meetDate = DateTime.now(); //
        }
      } else {
        meetDate =
            DateTime.now(); // Если тип неожиданный, используем текущую дату
      }

      // Проверяем, прошло ли больше 24 часов
      if (meetDate.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
        // Если встреча прошла более 24 часов назад
        meetsCollection.doc(meetDoc.id).update({'onHistory': true});
        pastMeets.add(meetDoc);
      }
    }

    setState(() {}); // Обновляем интерфейс после загрузки
  }

  // Метод для принятия запроса
  _acceptRequest(String meetId) async {
    final meetDoc = await meetsCollection.doc(meetId).get();
    Map<String, dynamic> meetData = meetDoc.data() as Map<String, dynamic>;

    // Добавляем текущего пользователя в users
    meetData['users'].add(username);
    meetData['requestUsers'].remove(username);

    // Обновляем документ
    await meetsCollection.doc(meetId).update({
      'users': meetData['users'],
      'requestUsers': meetData['requestUsers'],
    });

    _loadMeets(); // Перезагружаем встречи после принятия
  }

  // Метод для отклонения запроса
  _declineRequest(String meetId) async {
    final meetDoc = await meetsCollection.doc(meetId).get();
    Map<String, dynamic> meetData = meetDoc.data() as Map<String, dynamic>;

    // Удаляем текущего пользователя из requestUsers
    meetData['requestUsers'].remove(username);

    // Обновляем документ
    await meetsCollection.doc(meetId).update({
      'requestUsers': meetData['requestUsers'],
    });

    _loadMeets(); // Перезагружаем встречи после отклонения
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
          child: Column(
            children: [
              // Список встреч, где текущий пользователь в users
              _buildMeetList(
                S.of(context).yourMeets,
                meetsCollection
                    .where('users', arrayContains: username)
                    .snapshots(),
                false,
              ),

              // Список встреч, где текущий пользователь в requestUsers
              _buildMeetList(
                S.of(context).meetsRequest,
                meetsCollection
                    .where('requestUsers', arrayContains: username)
                    .snapshots(),
                true,
              ),

              // Список прошедших встреч
              _buildMeetList(
                S.of(context).pastMeetings,
                meetsCollection.where('onHistory', isEqualTo: true).snapshots(),
                false,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "accountButton",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountPage()),
                );
              },
              backgroundColor: Color.fromRGBO(148, 185, 255, 1),
              child: Icon(Icons.manage_accounts_outlined),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 36,
            child: FloatingActionButton(
              heroTag: "backButton",
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MapScreen()));
              },
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }

  // Виджет для отображения списка встреч
  Widget _buildMeetList(
      String title, Stream<QuerySnapshot> stream, bool isRequestList) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final List<DocumentSnapshot> meetList = snapshot.data!.docs;

        if (meetList.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: TextStyle(fontSize: 20)),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: meetList.length,
              itemBuilder: (context, index) {
                final meetData = meetList[index].data() as Map<String, dynamic>;
                final userList = meetData['users'] as List<dynamic>;

                String userNames =
                    userList.isEmpty ? 'No users' : userList.join(', ');

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MeetProfilePage(
                                  meetData: meetData,
                                  meetId: meetList[index].id)));
                    },
                    title: Text(meetData['name'] ?? 'No Title'),
                    subtitle: Text(S.of(context).members + userNames),
                    trailing: isRequestList
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                color: Colors.green,
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  _acceptRequest(meetList[index].id);
                                },
                              ),
                              IconButton(
                                color: Colors.red,
                                icon: Icon(Icons.cancel),
                                onPressed: () {
                                  _declineRequest(meetList[index].id);
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
