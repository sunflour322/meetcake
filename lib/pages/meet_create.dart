import 'package:flutter/material.dart';
import 'package:meetcake/generated/l10n.dart';
import 'package:meetcake/theme_lng/change_lng.dart';
import 'package:meetcake/theme_lng/change_theme.dart';
import 'package:provider/provider.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:toast/toast.dart';

class MeetCreatePage extends StatefulWidget {
  final SearchItem? searchItem;
  final Point? point;
  const MeetCreatePage(
      {super.key, required this.searchItem, required this.point});

  @override
  State<MeetCreatePage> createState() => _MeetCreatePageState();
}

class _MeetCreatePageState extends State<MeetCreatePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  List<String> friends = [];
  double completion = 0;

  void updateCompletion() {
    int filledFields = 0;
    if (nameController.text.isNotEmpty) filledFields++;
    if (timeController.text.isNotEmpty) filledFields++;
    if (locationController.text.isNotEmpty) filledFields++;
    if (friends.isNotEmpty) filledFields++;
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
    // TODO: implement initState
    super.initState();
    locationControllerValue();
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
                  friends.isEmpty
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
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: friends.length,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(friends[index]),
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
              onPressed: addFriend,
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

  Widget _buildTextField(TextEditingController controller, IconData icon,
      String hint, VoidCallback onChanged) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 35,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(style: BorderStyle.solid, width: 2)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: TextField(
                  style: TextStyle(
                      fontSize: 20,
                      color: themeProvider.theme.primaryColor,
                      fontWeight: FontWeight.bold),
                  controller: controller,
                  onChanged: (text) => onChanged(),
                  decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                          color:
                              themeProvider.theme.primaryColor.withOpacity(0.5),
                          fontWeight: FontWeight.bold),
                      border: InputBorder.none),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
