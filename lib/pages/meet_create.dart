import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MeetCreatePage extends StatefulWidget {
  const MeetCreatePage({super.key, required Point point});

  @override
  State<MeetCreatePage> createState() => _MeetCreatePageState();
}

class _MeetCreatePageState extends State<MeetCreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 50, 20, 0),
          child: GestureDetector(
            onTap: () {
              Navigator.popAndPushNamed(context, '/meets');
            },
            child: Container(
              alignment: Alignment.topRight,
              child: Image.asset(
                'assets/minilogo.png',
                scale: 2,
              ),
            ),
          ),
        ),
        Row(
          children: [Icon(Icons.abc), TextField()],
        ),
        Row(
          children: [Icon(Icons.abc), TextField()],
        ),
        Row(
          children: [Icon(Icons.abc), TextField()],
        ),
      ],
    ));
  }
}
