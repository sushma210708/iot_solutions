import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final apiKey = "AIzaSyCnnfz7qX2Kw6bcwR7eJ9004e1_USU1RXY";
  final email = "supertest889@test.com"; // This user exists in DB as 'user'. Let's see if syncUser crashes when updating them.
  final baseUrl = "https://iot-solutions.onrender.com/api";
  
  print("1. Signing in with Firebase Auth...");
  final authRes = await http.post(
    Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey"),
    headers: {"Content-Type": "application/json"},
    body: json.encode({"email": email, "password": "password123", "returnSecureToken": true}),
  );
  
  if (authRes.statusCode != 200) {
    print("Auth failed: ${authRes.body}");
    return;
  }
  
  final token = json.decode(authRes.body)['idToken'];
  
  print("2. Calling /auth/sync...");
  final syncRes = await http.post(
    Uri.parse("$baseUrl/auth/sync"),
    headers: {"Authorization": "Bearer $token"},
  );
  print("Sync Response: ${syncRes.statusCode} - ${syncRes.body}");
}
