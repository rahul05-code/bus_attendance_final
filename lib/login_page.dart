import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatelessWidget {
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  void login(BuildContext context) async {
    final phone = phoneCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (phone.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      // Login with Firebase Auth
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: "$phone@app.com", password: pass);

      // Fetch user details from Firestore
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .get();

      if (!doc.exists) throw Exception("User data not found");

      final userData = doc.data()!;
      final userString =
          "${userData['name']},${userData['phone']},${userData['city']},${userData['bus']},${userData['stop']}";

      // Store in SharedPreferences
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
            controller: phoneCtrl,
            decoration: InputDecoration(labelText: "Phone"),
            keyboardType: TextInputType.phone,
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
