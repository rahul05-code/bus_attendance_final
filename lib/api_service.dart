import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApiService {
  // ✅ Register User
  static Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String phone,
    String city,
    String bus,
    String stop,
    String password,
  ) async {
    try {
      UserCredential userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set({
        "name": name,
        "email": email,
        "phone": phone,
        "city": city,
        "bus": bus,
        "stop": stop,
      });

      return {"status": "success"};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // ✅ Login User
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return {"status": "success"};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // ✅ Mark Attendance
  static Future<Map<String, dynamic>> markAttendance(
    BuildContext context,
    String name,
    String phone,
    String city,
    String bus,
    String stop,
  ) async {
    try {
      final date = DateTime.now().toIso8601String().split("T")[0];
      final time = TimeOfDay.now().format(context);

      await FirebaseFirestore.instance.collection('attendance').add({
        "name": name,
        "phone": phone,
        "city": city,
        "bus": bus,
        "stop": stop,
        "date": date,
        "time": time,
      });

      return {"status": "success"};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}
