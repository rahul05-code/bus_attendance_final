import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {
  final String endpoint = 'YOUR_SCRIPT_URL';
  Future<Map> register(...) async {
    var res = await http.post(Uri.parse(endpoint), body: {
      'action':'register', 'phone':phone,'name':name,'city':city,'bus':bus,'stop':stop,'password':password
    });
    return jsonDecode(res.body);
  }
  Future<Map> login(...) async { /* similarly with action=login */ }
  Future<Map> scan(String phone) async {
    var res = await http.post(Uri.parse(endpoint), body:{'action':'scan','phone':phone});
    return jsonDecode(res.body);
  }
}
