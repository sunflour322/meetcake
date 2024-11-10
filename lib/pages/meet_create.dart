import 'package:flutter/material.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:toast/toast.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MeetCreatePage extends StatefulWidget {
  final Point point;

  const MeetCreatePage({super.key, required this.point});

  @override
  State<MeetCreatePage> createState() => _MeetCreatePageState();
}

class _MeetCreatePageState extends State<MeetCreatePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  List<String> friends = [];
  double completion = 0;

  void updateCompletion() {
    int filledFields = 0;
    if (nameController.text.isNotEmpty) filledFields++;
    if (descriptionController.text.isNotEmpty) filledFields++;
    if (locationController.text.isNotEmpty) filledFields++;
    if (friends.length != 0) filledFields++;
    setState(() {
      completion = filledFields / 4;
    });
  }

  void addFriend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Добавить друга"),
        content: TextField(
          onSubmitted: (value) {
            setState(() {
              friends.add(value);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void submit() {
    if (completion == 1) {
      // Логика принятия записи
    } else {
      Toast.show(S.of(context).fillInTheFields);
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
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
              _buildTextField(
                  nameController, Icons.person, 'Название', updateCompletion),
              _buildTextField(descriptionController, Icons.description,
                  'Описание', updateCompletion),
              _buildTextField(locationController, Icons.location_on, 'Локация',
                  updateCompletion),
              Expanded(
                child: friends.isEmpty
                    ? Center(
                        child: Column(
                        children: [
                          Image.asset(
                            'assets/utka.gif',
                            scale: 0.8,
                          ),
                          Text(S.of(context).noOne),
                        ],
                      ))
                    : ListView.builder(
                        itemCount: friends.length,
                        itemBuilder: (context, index) => ListTile(
                          title: Text(friends[index]),
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(),
                      onPressed: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back),
                    ),
                    ElevatedButton(
                      onPressed: addFriend,
                      child: Icon(Icons.person_add),
                    ),
                    GestureDetector(
                      onTap: submit,
                      child: Container(
                        height: 70,
                        width: 70,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: completion,
                              strokeWidth: 5,
                              color: Colors.green,
                            ),
                            Icon(Icons.check, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon,
      String hint, VoidCallback onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (text) => onChanged(),
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
