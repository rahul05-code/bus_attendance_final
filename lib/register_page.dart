import 'package:flutter/material.dart';
import 'api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final stopCtrl = TextEditingController();

  String? city, bus;
  bool isLoading = false;

  final cities = ["Morbi", "Rajkot", "Gondal", "Tankara", "Jasdan", "Wankaner"];
  final buses = [
    "Morbi(Big)",
    "Morbi(Small)",
    "Gondal(Big)",
    "Gondal(Small)",
    "Rajkot",
    "Jasdan",
    "Wankaner"
  ];

  void register(BuildContext context) async {
    if (city == null || bus == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select city and bus")));
      return;
    }

    if (nameCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        stopCtrl.text.isEmpty ||
        passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password must be at least 6 characters")));
      return;
    }

    setState(() => isLoading = true);

    final res = await ApiService.registerUser(
      nameCtrl.text.trim(),
      emailCtrl.text.trim(),
      phoneCtrl.text.trim(),
      city!,
      bus!,
      stopCtrl.text.trim(),
      passCtrl.text.trim(),
    );

    setState(() => isLoading = false);

    final message =
        res["status"] == "success" ? "Registered successfully" : res["message"];

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    if (res["status"] == "success") {
      Navigator.pop(context); // Return to login screen
    }
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
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Email")),
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
            onPressed: isLoading ? null : () => register(context),
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text("Register"),
          ),
        ]),
      ),
    );
  }
}
