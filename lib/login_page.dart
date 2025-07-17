import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'admin_page.dart';

class LoginPage extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void login(BuildContext context) async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // 🔐 Admin login check
    if (email == "admin@bus.com" && pass == "admin123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminPage()),
      );
      return;
    }

    try {
      // 🔐 Regular Firebase Auth login
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .get();

      if (!doc.exists) throw Exception("User data not found");

      final userData = doc.data()!;
      final userString =
          "${userData['name']},${userData['phone']},${userData['city']},${userData['bus']},${userData['stop']}";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user", userString);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          TextField(
            controller: emailCtrl,
            decoration: InputDecoration(labelText: "Email or Admin ID"),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: passCtrl,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => login(context),
            child: Text("Login"),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RegisterPage()),
            ),
            child: Text("Don't have an account? Register"),
          ),
        ]),
      ),
    );
  }
}
