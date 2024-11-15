import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetcake/database/collections/meets_collection.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/pages/account.dart';
import 'package:meetcake/user_service/service.dart';

class MeetPage extends StatefulWidget {
  const MeetPage({super.key});

  @override
  State<MeetPage> createState() => _MeetPageState();
}

class _MeetPageState extends State<MeetPage> {
  AuthService _authService = AuthService();
  MeetsCRUD _meetsCRUD = MeetsCRUD();
  final CollectionReference meetsCollection =
      FirebaseFirestore.instance.collection('meets');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<QuerySnapshot>(
        future: meetsCollection.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Scaffold(
              body: Column(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.popAndPushNamed(context, '/acc');
                      },
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
                          child: Container(
                            alignment: Alignment.topRight,
                            child: Icon(
                              Icons.manage_accounts_outlined,
                              size: 60,
                            ),
                          ))),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Image.asset('assets/catRainbow.gif', scale: 1.5),
                          Text(
                            S.of(context).noMeetings,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ), // путь к GIF
            );
          }

          final meetDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: meetDocs.length,
            itemBuilder: (context, index) {
              final meetData = meetDocs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(meetData['title'] ?? 'No Title'),
                subtitle: Text(meetData['description'] ?? 'No Description'),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AccountPage()));
        },
        backgroundColor: Color.fromRGBO(148, 185, 255, 1),
        child: Icon(Icons.manage_accounts_outlined),
      ),
    );
  }
}
