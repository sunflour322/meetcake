import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetcake/database/collections/user_collection.dart';
import 'package:meetcake/pages/meets.dart';
import 'package:meetcake/theme_lng/change_theme.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MeetProfilePage extends StatefulWidget {
  final Map<String, dynamic> meetData;
  final String meetId;
  const MeetProfilePage(
      {super.key, required this.meetData, required this.meetId});

  @override
  State<MeetProfilePage> createState() => _MeetProfilePageState();
}

class _MeetProfilePageState extends State<MeetProfilePage> {
  late double latitude;
  late double longitude;
  late String meetName;
  late String datetime;
  late List<dynamic> users;
  late DateTime meetDateTime;
  late Duration remainingTime;
  late Timer timer;
  String? username;
  UserCRUD _userCRUD = UserCRUD();
  final TextEditingController messageController = TextEditingController();

  bool isMeetOver = false; // Флаг завершения встречи
  final Completer<YandexMapController> mapControllerCompleter =
      Completer<YandexMapController>();

  List<MapObject> mapObjects = [];

  @override
  void initState() {
    super.initState();
    latitude = widget.meetData['lat'];
    longitude = widget.meetData['long'];
    meetName = widget.meetData['name'];
    datetime = widget.meetData['datetime'];
    users = widget.meetData['users'];
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _userCRUD.fetchUser().then((value) {
        setState(() {
          username = value?['username'];
        });
      });
    }
    try {
      meetDateTime = DateTime.parse(widget.meetData['datetime']);
    } catch (e) {
      print("Ошибка парсинга даты: $e");
      meetDateTime = DateTime.now(); // Установите текущую дату как резерв
    }

    remainingTime = meetDateTime.difference(DateTime.now());
    isMeetOver = remainingTime.isNegative; // Устанавливаем флаг при старте
    timer = Timer.periodic(Duration(seconds: 1), _updateRemainingTime);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final message = {
      'sender': '$username', // Замените на идентификатор текущего пользователя
      'text': messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('meets')
        .doc(widget.meetId)
        .collection('messages')
        .add(message);

    messageController.clear();
  }

  void _updateRemainingTime(Timer timer) {
    if (isMeetOver) return; // Не обновляем состояние, если встреча завершена

    setState(() {
      remainingTime = meetDateTime.difference(DateTime.now());

      if (remainingTime.isNegative) {
        remainingTime = Duration.zero;
        isMeetOver = true; // Устанавливаем флаг
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String formattedTime = _formatDuration(remainingTime);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Основной контент страницы
            Column(
              children: [
                SizedBox(height: 10),

                // Верхняя треть экрана: Информация о встрече
                isMeetOver
                    ? Center(
                        child: Text(
                          "Время вышло",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.av_timer_outlined, size: 60),
                          Text(formattedTime, style: TextStyle(fontSize: 20)),
                        ],
                      ),
                SizedBox(height: 10),

                // Остальные элементы интерфейса
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(148, 185, 255, 1))),
                        onPressed: () {
                          _showMapDialog(context);
                        },
                        child: Icon(Icons.map_outlined, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(148, 185, 255, 1))),
                        onPressed: () {
                          _showUsersDialog(context);
                        },
                        child: Icon(Icons.people_alt, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                // Половина экрана: чат
                Expanded(
                  child: Column(
                    children: [
                      // Чат
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5), // Отступы
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).cardColor, // Фон контейнера
                            borderRadius:
                                BorderRadius.circular(20), // Закругление углов
                            border: Border.all(
                                color: Colors.grey.shade300,
                                width: 3), // Граница
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                20), // Чтобы содержимое тоже имело закругленные углы
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('meets')
                                  .doc(widget.meetId)
                                  .collection('messages')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              initialData: null,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    snapshot.data == null) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                final messages = snapshot.data?.docs ?? [];

                                return ListView.builder(
                                  reverse: true,
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final message = messages[index].data()
                                        as Map<String, dynamic>;
                                    final isCurrentUser =
                                        message['sender'] == "$username";

                                    return Align(
                                      alignment: isCurrentUser
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isCurrentUser
                                              ? Colors.blue
                                              : Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          message['text'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Поле ввода сообщений
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black
                              .withOpacity(0.7), // Полупрозрачный фон
                          borderRadius:
                              BorderRadius.circular(20), // Закругление углов
                          border: Border.all(
                              color: Colors.grey.shade300, width: 3), // Граница
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: messageController,
                                style: TextStyle(
                                    color: Colors.white), // Цвет текста
                                decoration: InputDecoration(
                                  hintText: "Введите сообщение...",
                                  hintStyle: TextStyle(
                                      color: Colors
                                          .grey.shade400), // Цвет подсказки
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send, color: Colors.orange),
                              onPressed: _sendMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Кнопка возврата
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MeetPage())); // Возврат на предыдущую страницу
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Форматирование оставшегося времени (часы:минуты:секунды)

  // Метод для отображения карты в диалоговом окне
  void _showMapDialog(BuildContext context) {
    ThemeProvider themeDate = ThemeProvider();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: YandexMap(
                    onMapCreated: (controller) {
                      _addMarker(
                          latitude, longitude); // Добавляем маркер на карту
                    },
                    mapObjects: mapObjects,
                    nightModeEnabled: themeDate.returnBoolTheme(),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Закрыть"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Метод для отображения списка пользователей в диалоговом окне
  void _showUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              spacing: 100,
              runSpacing: 20,
              children: List.generate(users.length, (index) {
                return Column(
                  children: [
                    _buildUserAvatar(index),
                    Text(users[index], style: TextStyle(fontSize: 20)),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  // Метод для создания аватара пользователя (можно заменить на изображение)
  Widget _buildUserAvatar(int index) {
    String userName = users[index];

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: userName)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return CircleAvatar(child: Icon(Icons.person));
        }

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          var userData = snapshot.data!.docs.first;
          String? profileImageUrl = userData['profileImageUrl'];

          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            return CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
              radius: 35,
            );
          } else {
            return CircleAvatar(child: Icon(Icons.person));
          }
        }

        return CircleAvatar(child: Icon(Icons.person));
      },
    );
  }

  // Форматирование оставшегося времени (часы:минуты:секунды)
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  // Метод для добавления метки на карту
  void _addMarker(double latitude, double longitude) async {
    final point = Point(latitude: latitude, longitude: longitude);

    final onTapLocation = PlacemarkMapObject(
      opacity: 1,
      mapId: const MapObjectId('onTapLocation'),
      point: point,
      icon: PlacemarkIcon.single(PlacemarkIconStyle(
        scale: 0.2,
        image: BitmapDescriptor.fromAssetImage('assets/circle.png'),
        rotationType: RotationType.noRotation,
      )),
    );

    setState(() {
      mapObjects.add(onTapLocation);
    });
    await _moveToResultLocation(point);
  }

  Future<void> _moveToResultLocation(Point point) async {
    final controller = await mapControllerCompleter.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: point, zoom: 16)),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 2),
    );
  }
}
