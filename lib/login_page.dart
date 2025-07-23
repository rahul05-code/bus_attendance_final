import 'package:bus_attendance_app/admin_page.dart';
import 'package:bus_attendance_app/register_page.dart';
import 'package:bus_attendance_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // Define your admin credentials
  final String adminEmail = "rahulkanzariya861@gmail.com";
  final String adminPassword = "rahul510205";

  void login(BuildContext context) async {
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      // Firebase login
      UserCredential userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);

      // Check if admin
      if (email == adminEmail && pass == adminPassword) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHomePage()),
        );
        return;
      }

      // Normal user - Fetch Firestore data
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User data not found")),
        );
        return;
      }

      final userData = doc.data()!;
      final userString =
          "${userData['name']},${userData['phone']},${userData['city']},${userData['bus']},${userData['stop']}";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("user", userString);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(),
        ),
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
        child: Column(
          children: [
            TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: "Email")),
            TextField(
                controller: passCtrl,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => login(context),
              child: Text("Login"),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    );
                  },
                  child: Text(
                    "Register here",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
