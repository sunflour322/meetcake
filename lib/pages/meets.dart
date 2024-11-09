import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/user_service/service.dart';

class MeetPage extends StatefulWidget {
  const MeetPage({super.key});

  @override
  State<MeetPage> createState() => _MeetPageState();
}

class _MeetPageState extends State<MeetPage> {
  AuthService _authService = AuthService();
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
            return Center(
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Image.asset('assets/catRainbow.gif', scale: 1.5),
                    Text(
                      S.of(context).noMeetings,
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    )
                  ],
                ),
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
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          _authService.logOut();
          setState(() {});
          Navigator.popAndPushNamed(context, '/');
        },
        backgroundColor: const Color.fromRGBO(148, 185, 255, 1),
        child: const Icon(Icons.manage_history, color: Colors.white),
      ),
    );
  }
}
