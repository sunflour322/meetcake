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
  const MeetCreatePage({
    super.key,
    required this.searchItem,
    required this.point,
    required this.meetId,
  });

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
  List<String> friendsList = [];
  List<dynamic> requestUsers = []; // Список друзей
  // Список выбранных друзей для приглашения
  String selectedCategory = 'Все';

  void updateCompletion() {
    int filledFields = 0;
    if (nameController.text.isNotEmpty) filledFields++;
    if (timeController.text.isNotEmpty) filledFields++;
    if (locationController.text.isNotEmpty) filledFields++;
    if (requestUsers != []) {
      filledFields++;
      print(requestUsers);
    } else if (requestUsers == []) {
      filledFields--;
    }
    ;
    // Проверка выбранных друзей
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
    _fetchFriendsList(); // Загрузить список друзей
  }

  Future<void> _fetchFriendsList() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    setState(() {
      friendsList = List<String>.from(userDoc['friends'] ?? []);
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
        heightFactor: 0.75, // Увеличим высоту для удобства
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

            // Список категорий
            List<String> categories = [
              'Все',
              'Спорт',
              'Кино',
              'Музыка',
              'Чтение',
              'Природа',
              'Путешествия',
              'Танцы',
              'Готовка'
            ];

            return FutureBuilder<List<dynamic>>(
              future: fetchRequestUser(),
              builder: (context, requestSnapshot) {
                if (!requestSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                requestUsers = requestSnapshot.data!;

                return Column(
                  children: [
                    SizedBox(height: 10),
                    // Добавляем кнопку для выбора категории
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        onChanged: (newCategory) {
                          setState(() {
                            selectedCategory = newCategory!;
                          });
                        },
                        items: categories
                            .map<DropdownMenuItem<String>>((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Ваши друзья'),
                            // Фильтруем друзей по выбранной категории
                            ...friends.map((friendName) {
                              bool isSelected =
                                  requestUsers.contains(friendName);
                              return FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('username', isEqualTo: friendName)
                                    .limit(1)
                                    .get(),
                                builder: (context, friendSnapshot) {
                                  if (!friendSnapshot.hasData) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (friendSnapshot.data!.docs.isEmpty) {
                                    return Container();
                                  }

                                  Map<String, dynamic> friendData =
                                      friendSnapshot.data!.docs.first.data()
                                          as Map<String, dynamic>;
                                  List<dynamic> friendCategories =
                                      friendData['categories'] ?? [];

                                  // Если категория друга соответствует выбранной, показываем его
                                  bool isCategoryMatched =
                                      selectedCategory == 'Все' ||
                                          friendCategories
                                              .contains(selectedCategory);

                                  print(selectedCategory);
                                  if (isCategoryMatched) {
                                    return _buildFriendTile(
                                        friendName, isSelected, requestUsers);
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<dynamic>> fetchRequestUser() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('meets')
        .doc(widget.meetId)
        .get();
    return List<dynamic>.from(userDoc['requestUsers'] ?? []);
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
      String friendName, bool isSelected, List<dynamic> requestUsers) {
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
      trailing: isSelected
          ? IconButton(
              onPressed: () async {
                // Обновляем локальный список requestUsers
                setState(() {});

                // Обновляем Firestore
                await _updateUserRequests(friendName, remove: true)
                    .whenComplete(() => setState(() {
                          requestUsers.remove(friendName);
                        }));
                updateCompletion();
              },
              icon: Icon(
                Icons.remove_circle,
                color: Colors.red, // Красная иконка для удаления
              ),
            )
          : IconButton(
              onPressed: () async {
                // Обновляем локальный список requestUsers
                setState(() {
                  requestUsers.add(friendName);
                });

                // Обновляем Firestore
                await _updateUserRequests(friendName, remove: false)
                    .whenComplete(() => setState(() {
                          requestUsers.add(friendName);
                        }));
                updateCompletion();
              },
              icon: Icon(
                Icons.add,
                color: Colors.green, // Зеленая иконка для добавления
              ),
            ),
    );
  }

  Future<void> _updateUserRequests(String friendName,
      {required bool remove}) async {
    try {
      final meetDocRef =
          FirebaseFirestore.instance.collection('meets').doc(widget.meetId);

      if (remove) {
        // Удаляем друга из списка запросов
        await meetDocRef.update({
          'requestUsers': FieldValue.arrayRemove([friendName]),
        });
      } else {
        // Добавляем друга в список запросов
        await meetDocRef.update({
          'requestUsers': FieldValue.arrayUnion([friendName]),
        });
      }
    } catch (e) {
      print('Ошибка при обновлении userRequests: $e');
      // Можно добавить обработку ошибок, например, показать Toast
    }
  }

  void submit() async {
    if (completion == 1) {
      // Убедитесь, что список друзей не пустой, прежде чем отправить приглашение

      if (requestUsers.isNotEmpty) {
        // Создаем запись о встрече в коллекции 'meets'
        await FirebaseFirestore.instance
            .collection('meets')
            .doc(widget.meetId)
            .update({
          'name': nameController.text,
          'datetime': timeController.text,

          // Добавляем в запросы всех выбранных друзей
        });
        print('успешно');
        //Toast.show(S.of(context).meetingCreated); // Показать уведомление о создании
      } else {
        //Toast.show(S.of(context).addFriendsToMeet); // Показать уведомление, что нужно добавить друзей
      }
    } else {
      Toast.show(S
          .of(context)
          .fillInTheFields); // Показать уведомление, если поля не заполнены
    }
  }

  Widget _buildUserAvatar(int index) {
    // Получаем имя пользователя из списка requestUsers
    String userName = requestUsers[index];

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: userName) // Фильтрация по полю username
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Пока данные загружаются, показываем индикатор загрузки
          return CircleAvatar(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Если ошибка при загрузке, показываем стандартный аватар
          return CircleAvatar(child: Icon(Icons.person));
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          // Если найден хотя бы один документ
          var userData = snapshot.data!.docs.first;

          // Проверка наличия поля profileImageUrl
          String? profileImageUrl = userData['profileImageUrl'];

          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            // Если URL изображения существует, показываем аватарку
            return CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
              radius: 35,
            );
          } else {
            // Если изображения нет, показываем стандартный аватар
            return CircleAvatar(child: Icon(Icons.person));
          }
        }

        // Если не найдено документов с таким username, показываем стандартный аватар
        return CircleAvatar(child: Icon(Icons.person));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    final theme = ThemeProvider();
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('meets')
            .doc(widget.meetId)
            .snapshots(),
        builder: (context, snapshot) {
          // Если данных нет (загрузка)
          if (!snapshot.hasData) {
            return Center(
                child:
                    CircularProgressIndicator()); // Показать индикатор загрузки
          }

          // Если произошла ошибка при получении данных
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    "Произошла ошибка при загрузке данных")); // Показать сообщение об ошибке
          }

          // Если данные успешно получены
          List<dynamic> requestUsers = snapshot.data!['requestUsers'] ?? [];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 50, 20, 0),
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.popAndPushNamed(context, '/meets'),
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
                            Icon(Icons.attachment,
                                color: Colors.grey, size: 35),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        style: BorderStyle.solid, width: 2)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                      border: InputBorder.none,
                                    ),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                      border: InputBorder.none,
                                    ),
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
                            Icon(Icons.location_on,
                                color: Colors.grey, size: 35),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        style: BorderStyle.solid, width: 2)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      requestUsers.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  Image.asset('assets/utka.gif'),
                                  Text(
                                    S.of(context).noOne,
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Wrap(
                                spacing: 100,
                                runSpacing: 20,
                                children:
                                    List.generate(requestUsers.length, (index) {
                                  return Column(
                                    children: [
                                      _buildUserAvatar(index),
                                      Text(requestUsers[index],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20)),
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
          );
        },
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
              opacity: completion > 0 ? 1 : 0, // Прозрачность кнопки
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
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                      CircularProgressIndicator(
                        value: completion,
                        strokeWidth: 5,
                        color: Colors.white,
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
