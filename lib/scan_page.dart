import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'api_service.dart';

class ScanPage extends StatefulWidget {
  final String name, phone, stop, city, bus;
  const ScanPage(
      {required this.name,
      required this.phone,
      required this.stop,
      required this.city,
      required this.bus});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool scanned = false;

  void onDetect(BarcodeCapture capture) async {
    if (scanned) return;

    scanned = true;
    await ApiService.markAttendance(widget.name, widget.phone, widget.stop,
        widget.city, widget.bus);
    Navigator.pop(context);
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
