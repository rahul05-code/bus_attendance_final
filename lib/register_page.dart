import 'package:flutter/material.dart';
import 'api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final stopCtrl = TextEditingController();

  String? city, bus;

  final cities = ["Morbi", "Rajkot", "Gondal", "Tankara", "Jasdal", "Wankaner"];
  final buses = [
    "Morbi(Big)",
    "Morbi(Small)",
    "Gondal(Big)",
    "Gondal(Small)",
    "Rajkot",
    "Jasdal",
    "Wankaner"
  ];

  void register(BuildContext context) async {
    if (city == null || bus == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select city and bus")));
      return;
    }

    final res = await ApiService.register(
      nameCtrl.text,
      phoneCtrl.text,
      city!,
      bus!,
      stopCtrl.text,
      passCtrl.text,
    );

    final message =
        res["status"] == "success" ? "Registered successfully" : res["message"];

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(children: [
          TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: "Name")),
          TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: "Phone")),
          DropdownButtonFormField(
              value: city,
              hint: Text("Select City"),
              items: cities
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => city = v)),
          DropdownButtonFormField(
              value: bus,
              hint: Text("Select Bus"),
              items: buses
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => bus = v)),
          TextField(
              controller: stopCtrl,
              decoration: InputDecoration(labelText: "Stop")),
          TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password")),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () => register(context), child: Text("Register")),
        ]),
      ),
    );
  }
}
