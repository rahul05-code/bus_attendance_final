import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {
  final String endpoint =
      'https://script.google.com/macros/s/AKfycbz3pz9IflpUXjI1LuDePfpKYbwUt7MMblUH-6GqQBKubjUg2z6zzJF_wn0FvERslhmtQQ/exec';

  Future<Map> register({
    required String phone,
    required String name,
    required String city,
    required String bus,
    required String stop,
    required String password,
  }) async {
    var res = await http.post(Uri.parse(endpoint), body: {
      'action': 'register',
      'phone': phone,
      'name': name,
      'city': city,
      'bus': bus,
      'stop': stop,
      'password': password,
    });

    return jsonDecode(res.body);
  }

  Future<Map> login({
    required String phone,
    required String password,
  }) async {
    var res = await http.post(Uri.parse(endpoint), body: {
      'action': 'login',
      'phone': phone,
      'password': password,
    });

    return jsonDecode(res.body);
  }

  Future<Map> scan(String phone) async {
    var res = await http.post(Uri.parse(endpoint), body: {
      'action': 'scan',
      'phone': phone,
    });

    return jsonDecode(res.body);
  }
}
