import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'scan_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "", phone = "", stop = "", city = "", bus = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      final uid = user.uid;
      final doc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          name = data["name"] ?? "";
          phone = data["phone"] ?? "";
          stop = data["stop"] ?? "";
          city = data["city"] ?? "";
          bus = data["bus"] ?? "";
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User data not found in Firestore")),
        );
        setState(() => isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading user: $e")),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome ${name.isNotEmpty ? name : ''}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: ElevatedButton(
                child: Text("Scan QR for Attendance"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScanPage(
                        name: name,
                        phone: phone,
                        stop: stop,
                        city: city,
                        bus: bus,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
