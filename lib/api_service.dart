import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String endpoint =
      "https://script.google.com/macros/s/AKfycbxA87twRX3s45sLzmns7HcOFf0ZxTtR0DWRpDHbjJLIqLGNYvX1O8H7YbRDQueJ9IA8/exec";

  static Future<Map<String, dynamic>> register(String name, String phone,
      String city, String bus, String stop, String pass) async {
    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "action": "register",
          "name": name,
          "phone": phone,
          "city": city,
          "bus": bus,
          "stop": stop,
          "password": pass,
        }),
      );

      print("Response status: ${res.statusCode}");
      print("Response headers: ${res.headers}");
      print("Raw response body: ${res.body}");

      return jsonDecode(res.body);
    } catch (e) {
      print("Exception caught: $e");
      return {"status": "error", "message": "Invalid server response"};
    }
  }

  static Future<Map<String, dynamic>> login(String phone, String pass) async {
    final res = await http.post(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"action": "login", "phone": phone, "password": pass}),
    );

    try {
      return jsonDecode(res.body);
    } catch (e) {
      print("Error decoding JSON: ${res.body}");
      return {"status": "error", "message": "Invalid server response"};
    }
  }

  static Future<Map<String, dynamic>> markAttendance(
      String name, String phone, String stop, String city, String bus) async {
    final date = DateTime.now().toString().split(" ")[0];
    final res = await http.post(
      Uri.parse(endpoint),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "attendance",
        "name": name,
        "phone": phone,
        "stop": stop,
        "city": city,
        "bus": bus,
        "date": date
      }),
    );

    try {
      return jsonDecode(res.body);
    } catch (e) {
      print("Error decoding JSON: ${res.body}");
      return {"status": "error", "message": "Invalid server response"};
    }
  }
}
