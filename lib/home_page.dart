import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'scan_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "", phone = "", stop = "", city = "", bus = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = prefs.getString("user")?.split(",");
    if (user != null) {
      setState(() {
        name = user[0];
        phone = user[1];
        city = user[2];
        bus = user[3];
        stop = user[4];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome $name")),
      body: Center(
          child: ElevatedButton(
        child: Text("Scan QR for Attendance"),
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ScanPage(
                    name: name,
                    phone: phone,
                    stop: stop,
                    city: city,
                    bus: bus))),
      )),
    );
  }
}
