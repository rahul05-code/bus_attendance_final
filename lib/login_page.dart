import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'api_service.dart';

class LoginPage extends StatelessWidget {
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void login(BuildContext context) async {
    final res = await ApiService.login(phoneCtrl.text, passCtrl.text);
    if (res["status"] == "success") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user", res["user"].join(","));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: "Phone")),
          TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: "Password")),
          ElevatedButton(onPressed: () => login(context), child: Text("Login")),
          TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage())), child: Text("Register")),
        ]),
      ),
    );
  }
}
