// Main Flutter app with Login, Register, Home, and QR Scanner functionality using Google Sheets backend

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Attendance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

const apiUrl = 'YOUR_DEPLOYED_SCRIPT_URL';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();
  final passController = TextEditingController();

  Future<void> login() async {
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'login',
      'phone': phoneController.text,
      'password': passController.text
    });
    final data = jsonDecode(res.body);
    if (data['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            phone: phoneController.text,
            user: data['user'],
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text(data['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone')),
            TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            ElevatedButton(onPressed: login, child: const Text('Login')),
            TextButton(
              child: const Text('Register here'),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterPage())),
            )
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final stopController = TextEditingController();
  final passController = TextEditingController();

  String city = 'Morbi';
  String bus = 'Morbi (big)';

  Future<void> register() async {
    final res = await http.post(Uri.parse(apiUrl), body: {
      'action': 'register',
      'name': nameController.text,
      'phone': phoneController.text,
      'city': city,
      'bus': bus,
      'stop': stopController.text,
      'password': passController.text
    });
    final data = jsonDecode(res.body);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(content: Text(data['message'])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone')),
            TextField(
                controller: stopController,
                decoration: const InputDecoration(labelText: 'Stop')),
            TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            DropdownButtonFormField(
              value: city,
              items: [
                'Morbi',
                'Rajkot',
                'Gondal',
                'Tankara',
                'Jasdal',
                'Wankaner'
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => city = val as String),
              decoration: const InputDecoration(labelText: 'City'),
            ),
            DropdownButtonFormField(
              value: bus,
              items: [
                'Morbi (big)',
                'Morbi (small)',
                'Gondal (big)',
                'Gondal (small)',
                'Rajkot',
                'Jasdal',
                'Wankaner'
              ].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) => setState(() => bus = val as String),
              decoration: const InputDecoration(labelText: 'Bus'),
            ),
            ElevatedButton(onPressed: register, child: const Text('Register')),
          ]),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String phone;
  final Map user;
  const HomePage({super.key, required this.phone, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Text('Welcome ${user['name']}'),
          Text('City: ${user['city']}'),
          Text('Bus: ${user['bus']}'),
          Text('Stop: ${user['stop']}'),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Scan QR to Mark Attendance'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QRScanPage(phone: phone),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

class QRScanPage extends StatelessWidget {
  final String phone;
  const QRScanPage({super.key, required this.phone});

  Future<void> scanAttendance(BuildContext context) async {
    final res = await http
        .post(Uri.parse(apiUrl), body: {'action': 'scan', 'phone': phone});
    final data = jsonDecode(res.body);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text(data['message'])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Scan QR')),
        body: MobileScanner(
          onDetect: (barcodeCapture) {
            final value = barcodeCapture.barcodes.first.rawValue;
            if (value != null && value == phone) {
              scanAttendance(context);
            } else {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  content: Text('Invalid QR'),
                ),
              );
            }
          },
        ));
  }
}
