import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScanPage extends StatefulWidget {
  final String name, phone, stop, city, bus;

  const ScanPage({
    required this.name,
    required this.phone,
    required this.stop,
    required this.city,
    required this.bus,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool scanned = false;

  void onDetect(BarcodeCapture capture) async {
    if (scanned) return;

    scanned = true;

    try {
      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd').format(now);
      final time = DateFormat('HH:mm:ss').format(now);

      await FirebaseFirestore.instance.collection("attendance").add({
        "name": widget.name,
        "phone": widget.phone,
        "stop": widget.stop,
        "city": widget.city,
        "bus": widget.bus,
        "date": date,
        "time": time,
        "timestamp": FieldValue.serverTimestamp(), // optional for sorting
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Attendance marked!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    Navigator.pop(context); // Return to home screen after scanning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR")),
      body: MobileScanner(
        onDetect: onDetect,
      ),
    );
  }
}
