import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final apiKey = "AIzaSyCnnfz7qX2Kw6bcwR7eJ9004e1_USU1RXY";
  final email = "test88899@test.com";
  
  print("Signing up...");
  final authRes = await http.post(
    Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey"),
    headers: {"Content-Type": "application/json"},
    body: json.encode({"email": email, "password": "password123", "returnSecureToken": true}),
  );
  
  if (authRes.statusCode != 200) {
    print("Auth failed: ${authRes.body}");
    return;
  }
  
  final token = json.decode(authRes.body)['idToken'];
  print("Token received.");
  
  print("Testing /admins with new token...");
  final adminRes = await http.get(
    Uri.parse("https://iot-solutions.onrender.com/api/admins"),
    headers: {"Authorization": "Bearer $token"},
  );
  print("Response code: ${adminRes.statusCode}");
  if (adminRes.statusCode == 200) {
    print("Success! A normal user CAN access /admins!");
  } else {
    print("Failed to access /admins: ${adminRes.body}");
  }
}
