import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MeetProfilePage extends StatefulWidget {
  final Map<String, dynamic> meetData;
  const MeetProfilePage({super.key, required this.meetData});

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

    meetDateTime = DateTime.parse(widget.meetData['datetime']);
    remainingTime = meetDateTime.difference(DateTime.now());

    // Запускаем таймер для обновления оставшегося времени каждую секунду
    timer = Timer.periodic(Duration(seconds: 1), _updateRemainingTime);
  }

  @override
  void dispose() {
    // Останавливаем таймер при выходе со страницы
    timer.cancel();
    super.dispose();
  }

  void _updateRemainingTime(Timer timer) {
    setState(() {
      remainingTime = meetDateTime.difference(DateTime.now());
      if (remainingTime.isNegative) {
        remainingTime = Duration.zero;
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatDuration(remainingTime);

    return Scaffold(
      appBar: AppBar(title: Text(meetName)),
      body: Column(
        children: [
          SizedBox(height: 10),

          // Верхняя треть экрана: Информация о встрече
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.av_timer_outlined, size: 60),
              Text(formattedTime, style: TextStyle(fontSize: 20))
            ],
          ),
          SizedBox(height: 10),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        style: BorderStyle.solid,
                        width: 5,
                        color: Colors.white)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                          border: Border.all(
                              style: BorderStyle.solid,
                              width: 5,
                              color: Colors.white)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Чат: ${users.join(', ')}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return ListTile(title: Text(''));
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                          border: Border.all(
                              style: BorderStyle.solid,
                              width: 5,
                              color: Colors.white)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: 'Введите сообщение...',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                onPressed: () {
                                  // Логика отправки сообщений
                                },
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Метод для отображения карты в диалоговом окне
  void _showMapDialog(BuildContext context) {
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
                      if (!mapControllerCompleter.isCompleted) {
                        mapControllerCompleter.complete(
                            controller); // Завершаем Future только один раз
                      }
                      _addMarker(
                          latitude, longitude); // Добавляем маркер на карту
                    },
                    mapObjects: mapObjects,
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
      onTap: (mapObject, point) {
        _moveToResultLocation(point);
      },
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
  }

  Future<void> _moveToResultLocation(Point point) async {
    final controller = await mapControllerCompleter.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: point, zoom: 16)),
      animation: const MapAnimation(type: MapAnimationType.smooth, duration: 2),
    );
  }
}
