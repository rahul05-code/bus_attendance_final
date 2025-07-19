import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QRGeneratorPage extends StatelessWidget {
  // Valid QR codes that can mark attendance
  static const List<String> validCodes = [
    "BUS_ATTENDANCE_2025",
    "ATTENDANCE_QR", 
    "BUS_SCAN_CODE"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Generator"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Valid QR Codes for Attendance:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "These are the QR code contents that will mark attendance when scanned:",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: validCodes.length,
                itemBuilder: (context, index) {
                  final code = validCodes[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          "${index + 1}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        code,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text("Tap to copy"),
                      trailing: Icon(Icons.copy),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Copied: $code"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        "How to create QR codes:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "1. Copy any of the codes above\n"
                    "2. Use any QR code generator website\n"
                    "3. Paste the code as text content\n"
                    "4. Generate and print the QR code\n"
                    "5. Only these QR codes will work for attendance",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}