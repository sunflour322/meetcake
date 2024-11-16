import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetcake/database/collections/user_collection.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/theme_lng/change_lng.dart';
import 'package:meetcake/theme_lng/change_theme.dart';
import 'package:meetcake/user_service/friendship_service.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:toast/toast.dart';

class MeetCreatePage extends StatefulWidget {
  final SearchItem? searchItem;
  final Point? point;
  final String? meetId;
  const MeetCreatePage(
      {super.key,
      required this.searchItem,
      required this.point,
      required this.meetId});

  @override
  State<MeetCreatePage> createState() => _MeetCreatePageState();
}

class _MeetCreatePageState extends State<MeetCreatePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final FriendshipService friendshipService = FriendshipService();
  final UserCRUD userCRUD = UserCRUD();
  String? userId;
  var username;
  double completion = 0;
  List<DocumentSnapshot> friendsList = []; // List to hold selected friends

  void updateCompletion() {
    int filledFields = 0;
    if (nameController.text.isNotEmpty) filledFields++;
    if (timeController.text.isNotEmpty) filledFields++;
    if (locationController.text.isNotEmpty) filledFields++;
    if (friendsList.isNotEmpty) filledFields++;
    setState(() {
      completion = filledFields / 4;
    });
  }

  void _selectDateTime() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      locale: localeProvider.locale,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final formattedDateTime =
            '${pickedDate.year}-${pickedDate.month}-${pickedDate.day} ${pickedTime.format(context)}';
        timeController.text = formattedDateTime;
        updateCompletion();
      }
    }
  }

  void locationControllerValue() {
    nameController.text = widget.meetId.toString();
    if (widget.searchItem != null) {
      locationController.text =
          '${widget.searchItem!.businessMetadata!.name} (${widget.searchItem!.businessMetadata!.address.formattedAddress})';
    } else {
      locationController.text =
          '${widget.point!.latitude}   ${widget.point!.longitude}';
    }
  }

  @override
  void initState() {
    super.initState();
    locationControllerValue();
    userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      userCRUD.fetchUser().then((value) {
        setState(() {
          username = value?['username'];
        });
      });
    }
  }

  Future<void> _fetchFriendsCount() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      friendsList = userDoc['friends'];
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

            List<dynamic> friendsList = snapshot.data!['friends'] ?? [];
            List<String> selectedFriends = List.from(friendsList);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Ваши друзья'),
                          ...friendsList.map((friendName) {
                            bool isSelected =
                                selectedFriends.contains(friendName);
                            return _buildFriendTile(friendName, isSelected,
                                (friendName) {
                              setState(() {
                                if (isSelected) {
                                  selectedFriends.remove(friendName);
                                } else {
                                  selectedFriends.add(friendName);
                                }
                                friendsList = List.from(selectedFriends);
                                updateCompletion();
                              });
                            });
                          }).toList(),
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
    ).whenComplete(() => setState(() {}));
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

  Widget _buildFriendTile(
      String friendName, bool isSelected, Function(String) onSelect) {
    return ListTile(
      leading: FutureBuilder<String?>(
        future: friendshipService.fetchUserImageUrl(friendName),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return CircleAvatar(
              backgroundImage: NetworkImage(snapshot.data!),
            );
          } else {
            return CircleAvatar(child: Icon(Icons.person)); // Default icon
          }
        },
      ),
      title: Text(friendName),
      trailing: IconButton(
        onPressed: () {
          onSelect(friendName); // Update selection when button pressed
        },
        icon: Icon(
          isSelected ? Icons.remove_circle : Icons.add_circle,
          color: isSelected ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  void submit() {
    if (completion == 1) {
      // Submit logic when form is completed
    } else {
      Toast.show(S.of(context).fillInTheFields);
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final theme = ThemeProvider();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 20, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.popAndPushNamed(context, '/meets'),
                      child: Container(
                        alignment: Alignment.topRight,
                        child: Image.asset('assets/minilogo.png', scale: 2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.attachment,
                          color: Colors.grey,
                          size: 35,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    style: BorderStyle.solid, width: 2)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 20,
                                    color: theme.theme.primaryColor,
                                    fontWeight: FontWeight.bold),
                                controller: nameController,
                                onChanged: (text) => updateCompletion(),
                                decoration: InputDecoration(
                                    hintText: S.of(context).nameMeet,
                                    hintStyle: TextStyle(
                                        color: theme.theme.primaryColor
                                            .withOpacity(0.5),
                                        fontWeight: FontWeight.bold),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _selectDateTime();
                          },
                          child: Icon(
                              size: 35,
                              Icons.date_range_outlined,
                              color: Colors.grey),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    style: BorderStyle.solid, width: 2)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 20,
                                    color: theme.theme.primaryColor,
                                    fontWeight: FontWeight.bold),
                                controller: timeController,
                                onChanged: (text) => updateCompletion(),
                                decoration: InputDecoration(
                                    hintText: S.of(context).time,
                                    hintStyle: TextStyle(
                                        color: theme.theme.primaryColor
                                            .withOpacity(0.5),
                                        fontWeight: FontWeight.bold),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 35,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    style: BorderStyle.solid, width: 2)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: TextField(
                                style: TextStyle(
                                    fontSize: 20,
                                    color: theme.theme.primaryColor,
                                    fontWeight: FontWeight.bold),
                                controller: locationController,
                                onChanged: (text) => updateCompletion(),
                                decoration: InputDecoration(
                                    hintText: S.of(context).location,
                                    hintStyle: TextStyle(
                                        color: theme.theme.primaryColor
                                            .withOpacity(0.5),
                                        fontWeight: FontWeight.bold),
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  friendsList.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              Image.asset('assets/utka.gif', scale: 0.8),
                              Text(S.of(context).noOne,
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Wrap(
                            spacing: 100,
                            runSpacing: 20,
                            children:
                                List.generate(friendsList.length, (index) {
                              return Column(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage(
                                        friendsList[index]['imageUrl']),
                                    radius: 35,
                                  ),
                                  SizedBox(
                                    width: 100, // Ограничение ширины текста
                                    child: FittedBox(
                                      fit: BoxFit
                                          .scaleDown, // Подгонка текста к ширине
                                      child: Text(
                                        friendsList[index]['name'],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            }),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'backButton',
              backgroundColor: Color.fromRGBO(148, 185, 255, 1),
              onPressed: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back),
            ),
            FloatingActionButton(
              heroTag: 'addFriendButton',
              backgroundColor: Color.fromRGBO(148, 185, 255, 1),
              onPressed: () => _showFriendsBottomSheet(context),
              child: Icon(Icons.person_add),
            ),
            Opacity(
              opacity: completion > 0
                  ? 1
                  : 0, // Кнопка прозрачная, если completion = 0
              child: GestureDetector(
                onTap: submit,
                child: Container(
                  height: 70,
                  width: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(148, 185, 255, 1),
                            borderRadius: BorderRadius.circular(50)),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          value: completion,
                          strokeWidth: 5,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
