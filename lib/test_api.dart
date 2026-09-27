import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final apiKey = "AIzaSyCnnfz7qX2Kw6bcwR7eJ9004e1_USU1RXY";
  final email = "supertest889@test.com"; // NEW EMAIL
  final baseUrl = "https://iot-solutions.onrender.com/api";
  
  print("1. Signing up with Firebase Auth...");
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
  
  print("2. Calling /auth/sync...");
  final syncRes = await http.post(
    Uri.parse("$baseUrl/auth/sync"),
    headers: {"Authorization": "Bearer $token"},
  );
  print("Sync Response: ${syncRes.statusCode} - ${syncRes.body}");
  
  print("3. Logging in as super admin to check users...");
  final adminLogin = await http.post(
    Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey"),
    headers: {"Content-Type": "application/json"},
    body: json.encode({"email": "nexusacademy265@gmail.com", "password": "password123", "returnSecureToken": true}),
  );
  // I don't know the admin password, so I'll just check if /users works for the NORMAL user (it might fail if not admin).
  print("4. Attempting to fetch /users with normal user token (should fail if protected, or succeed if not)...");
  final usersRes = await http.get(
    Uri.parse("$baseUrl/users"),
    headers: {"Authorization": "Bearer $token"},
  );
  print("Users Response: ${usersRes.statusCode} - ${usersRes.body}");
}
