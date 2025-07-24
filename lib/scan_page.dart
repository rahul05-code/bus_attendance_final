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
    required String field,
    required String sem,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool scanned = false;

  // Define the specific QR code content that should trigger attendance
  //static const String VALID_QR_CODE = "BUS_ATTENDANCE_2025";
  // You can also use multiple valid codes:
  static const List<String> VALID_QR_CODES = [
    "BUS_MORBI_BIG",
    "BUS_MORBI_SMALL",
    "BUS_GONDAL_BIG",
    "BUS_GONDAL_SMALL",
    "BUS_RAJKOT",
    "BUS_JASDAN",
    "BUS_WANKANER",
  ];

  void onDetect(BarcodeCapture capture) async {
    if (scanned) return;

    // Get the scanned QR code content
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrContent = barcodes.first.rawValue;
    if (qrContent == null || qrContent.isEmpty) {
      _showErrorDialog("Invalid QR Code", "Could not read QR code content.");
      return;
    }

    // Check if the scanned QR code is valid for attendance
    if (!VALID_QR_CODES.contains(qrContent.trim())) {
      _showErrorDialog("Invalid QR Code",
          "This QR code is not valid for attendance marking.\n\nScanned: $qrContent");
      return;
    }

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
        "qr_code": qrContent, // Store the QR code that was scanned
      });

      _showSuccessDialog("Attendance Marked Successfully!",
          "Your attendance has been recorded for $date at $time");
    } catch (e) {
      scanned = false; // Reset scanned flag on error
      _showErrorDialog("Error", "Failed to mark attendance: $e");
      return;
    }

    // Return to home screen after successful attendance marking
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.green)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to home
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  scanned = false; // Reset to allow scanning again
                });
              },
              child: Text("Try Again"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to home
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR for Attendance"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.red[50],
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner, size: 48, color: Colors.red),
                SizedBox(height: 8),
                Text(
                  "Scan the official bus attendance QR code",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  "Only authorized QR codes will mark attendance",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: MobileScanner(
              onDetect: onDetect,
            ),
          ),
        ],
      ),
    );
  }
}
