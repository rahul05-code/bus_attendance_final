import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class ScanPage extends StatefulWidget {
  final String name, phone, stop, city, bus, field, sem; // Added field and sem to required

  const ScanPage({
    super.key, // Added super.key for best practice
    required this.name,
    required this.phone,
    required this.stop,
    required this.city,
    required this.bus,
    required this.field, // Now required
    required this.sem, // Now required
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool scanned = false; // Flag to prevent multiple scans

  // Define the specific QR code content that should trigger attendance
  static const List<String> VALID_QR_CODES = [
     "BUS_MORBI_BIG",
    "BUS_MORBI_SMALL",
    "BUS_GONDAL_BIG",
    "BUS_GONDAL_SMALL",
    "BUS_RAJKOT",
    "BUS_JASDAN",
    "BUS_WANKANER",

  ];

  // Controller for MobileScanner (provides more control over the camera)
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, // Adjust detection speed
    returnImage: false, // No need to return image data for this use case
  );

  @override
  void dispose() {
    cameraController.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  void onDetect(BarcodeCapture capture) async {
    if (scanned) return; // Prevent multiple scans

    // Pause the camera to prevent further detections while processing
    cameraController.stop();

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      _showErrorDialog("Scan Error", "No QR code detected. Please try again.");
      return;
    }

    final String? qrContent = barcodes.first.rawValue;

    if (qrContent == null || qrContent.isEmpty) {
      _showErrorDialog("Invalid QR Code", "Could not read QR code content.");
      _resetScanner(); // Reset scanner after showing dialog
      return;
    }

    // Check if the scanned QR code is valid for attendance
    if (!VALID_QR_CODES.contains(qrContent.trim())) {
      _showErrorDialog(
          "Invalid QR Code",
          "This QR code is not valid for attendance marking.\n\n"
              "Scanned: '$qrContent'"); // Show actual scanned content
      _resetScanner(); // Reset scanner after showing dialog
      return;
    }

    setState(() {
      scanned = true; // Set scanned to true to prevent re-entry
    });

    try {
      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd').format(now);
      final time = DateFormat('HH:mm:ss').format(now);

      await FirebaseFirestore.instance.collection("attendance").add({
        "name": widget.name,
        "phone": widget.phone,
        "field": widget.field, // Added field
        "sem": widget.sem, // Added sem
        "stop": widget.stop,
        "city": widget.city,
        "bus": widget.bus,
        "date": date,
        "time": time,
        "timestamp": FieldValue.serverTimestamp(), // Optional for sorting
        "qr_code": qrContent, // Store the QR code that was scanned
      });

      _showSuccessDialog("Attendance Marked Successfully!",
          "Your attendance for bus ${widget.bus} has been recorded on $date at $time.");
    } catch (e) {
      _showErrorDialog("Error", "Failed to mark attendance: $e");
      _resetScanner(); // Reset scanner on error
    }
  }

  // Helper to reset scanner state and resume camera
  void _resetScanner() {
    setState(() {
      scanned = false;
    });
    cameraController.start(); // Resume camera scanning
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap OK to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 30),
              const SizedBox(width: 10),
              Expanded( // Use Expanded to prevent overflow for long titles
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Pop the dialog first
                Navigator.of(context).pop();
                // Then pop the ScanPage to go back to the HomePage
                Navigator.of(context).pop();
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 30),
              const SizedBox(width: 10),
              Expanded( // Use Expanded to prevent overflow for long titles
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the current error dialog
                _resetScanner(); // Allow scanning again
              },
              child: const Text(
                "Try Again",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryRed = Colors.red.shade700;
    final Color lightRed = Colors.red.shade100;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scan Bus Attendance",
          style: TextStyle(fontWeight: FontWeight.bold), // Make app bar title bold
        ),
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true, // Center the title for a cleaner look
        elevation: 0, // Remove elevation for a flatter design that blends with the banner
      ),
      body: Column(
        children: [
          // Informational Banner with ClipRRect for rounded bottom corners
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)), // Smooth rounded bottom
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25), // Increased padding
              decoration: BoxDecoration(
                color: lightRed, // Light red background
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Slightly stronger shadow
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_scanner, size: 60, color: primaryRed), // Larger icon
                  const SizedBox(height: 15),
                  Text(
                    "Scan Your Bus QR Code", // More direct title
                    style: TextStyle(
                      fontSize: 22, // Larger font size
                      fontWeight: FontWeight.w800, // Extra bold
                      color: primaryRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Position the QR code clearly within the frame to record your attendance.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[800], // Darker grey for better contrast
                      height: 1.4, // Line height for better readability
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController, // Use the controller
                  onDetect: onDetect,
                  // The `overlay` property is deprecated and will be removed in future versions.
                  // We're moving to a Stack-based approach for the overlay for better control.
                ),
                // Custom overlay for the scanning frame and darkened background
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250, // Size of the scanning area
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryRed, width: 3.5), // Thicker, vibrant red border
                      borderRadius: BorderRadius.circular(20), // More rounded corners
                    ),
                  ),
                ),
                // Semi-transparent overlay to focus on the scan area
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6), // Darker overlay for more contrast
                    BlendMode.srcOut, // This blend mode creates the "hole"
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent, // Required for ColorFiltered to work as expected
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 250, // Must match the size of the scanning box
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.black, // Color of the "hole"
                              borderRadius: BorderRadius.circular(20), // Must match the scanning box border radius
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Text overlay for guidance
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedContainer( // Add AnimatedContainer for a subtle animation on state change
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: scanned ? Colors.green.shade700.withOpacity(0.8) : Colors.black87, // Change color when processing
                        borderRadius: BorderRadius.circular(30), // More rounded pill shape
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        scanned ? "Processing Attendance..." : "Scanning for QR Code...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600, // Slightly bolder text
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}