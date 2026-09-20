import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/product.dart';
import '../models/achievement.dart';
import '../models/hero.dart';
import '../models/project.dart';
import '../models/update.dart';
import '../models/admin_user.dart';
import '../models/mentor.dart';
import '../models/footer.dart';
import '../models/inquiry.dart';
import '../models/challenge.dart';
import '../models/testimonial.dart';
import '../models/service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class ApiService {
  static const String _localUrl = 'http://localhost:5000/api';
  static const String _prodUrl = 'https://iot-solutions.onrender.com/api';
  static const String baseUrl = kReleaseMode ? _prodUrl : _localUrl;

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> productsJson = data['data'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load products');
  }

  Future<Product> getProductById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        try {
          return Product.fromJson(data['data']);
        } catch (e) {
          throw Exception('Model parsing error: $e');
        }
      }
    }
    throw Exception('Failed to load product details: ${response.statusCode} - ${response.body}');
  }

  Future<Map<String, dynamic>> uploadImage(Uint8List bytes, String filename) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/image'));
    
    // Determine mime type to prevent backend rejection
    String ext = 'jpeg';
    if (filename.toLowerCase().endsWith('.png')) ext = 'png';
    else if (filename.toLowerCase().endsWith('.gif')) ext = 'gif';
    else if (filename.toLowerCase().endsWith('.webp')) ext = 'webp';

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: filename,
      contentType: MediaType('image', ext),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data; // contains imageUrl and publicId
      }
    }
    throw Exception('Failed to upload image: ${response.body}');
  }

  Future<List<Map<String, dynamic>>> uploadMultipleImages(List<Uint8List> bytesList, List<String> filenames) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/images'));
    
    for (int i = 0; i < bytesList.length; i++) {
      String filename = filenames[i];
      String ext = 'jpeg';
      if (filename.toLowerCase().endsWith('.png')) ext = 'png';
      else if (filename.toLowerCase().endsWith('.gif')) ext = 'gif';
      else if (filename.toLowerCase().endsWith('.webp')) ext = 'webp';

      request.files.add(http.MultipartFile.fromBytes(
        'images', // Must match backend upload.array('images')
        bytesList[i],
        filename: filename,
        contentType: MediaType('image', ext),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['images']);
      }
    }
    throw Exception('Failed to upload multiple images');
  }

  Future<Product> createProduct(Map<String, dynamic> productData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(productData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Product.fromJson(data['data']);
      }
    }
    throw Exception('Failed to create product');
  }

  Future<void> deleteProduct(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete product');
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> updates, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update product');
    }
  }

  // --- Achievements ---

  Future<List<Achievement>> getAchievements() async {
    final response = await http.get(Uri.parse('$baseUrl/achievements'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> achievementsJson = data['data'];
        return achievementsJson.map((json) => Achievement.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load achievements');
  }

  Future<Achievement> createAchievement(Map<String, dynamic> achievementData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/achievements'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(achievementData),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Achievement.fromJson(data['data']);
      }
    }
    throw Exception('Failed to create achievement');
  }

  Future<void> updateAchievement(String id, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/achievements/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update achievement');
    }
  }

  Future<void> deleteAchievement(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/achievements/$id'));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete achievement');
    }
  }

  // --- Hero Content ---

  Future<HeroContent> getHeroContent() async {
    final response = await http.get(Uri.parse('$baseUrl/hero'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return HeroContent.fromJson(data['data']);
      }
    }
    throw Exception('Failed to load hero content');
  }

  Future<void> updateHeroContent(Map<String, dynamic> updates, String? token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/hero'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update hero content: ${response.body}');
    }
  }

  // --- Footer Content ---
  
  Future<FooterContent> getFooterContent() async {
    final response = await http.get(Uri.parse('$baseUrl/footer'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return FooterContent.fromJson(data['data']);
      }
    }
    throw Exception('Failed to load footer content');
  }

  Future<void> updateFooterContent(Map<String, dynamic> data, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/footer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update footer content: ${response.body}');
    }
  }

  // --- Auth & Profile ---
  
  Future<AdminUser> getCurrentUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['user'] != null) {
        return AdminUser.fromJson(data['user']);
      }
    }
    throw Exception('Failed to load user profile: ${response.statusCode} ${response.body}');
  }

  // --- Admins ---

  Future<List<AdminUser>> getAdmins(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admins'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> adminsJson = data['data'];
        return adminsJson.map((json) => AdminUser.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load admins: ${response.body}');
  }

  Future<AdminUser> createAdmin(Map<String, dynamic> adminData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admins'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(adminData),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return AdminUser.fromJson(data['data']);
      }
    }
    throw Exception('Failed to create admin: ${response.body}');
  }

  Future<void> updateAdmin(String id, Map<String, dynamic> updates, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admins/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update admin: ${response.body}');
    }
  }

  Future<void> deleteAdmin(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admins/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete admin: ${response.body}');
    }
  }

  // --- Mentors ---

  Future<List<Mentor>> getMentors() async {
    final response = await http.get(Uri.parse('$baseUrl/mentors'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> mentorsJson = data['data'];
        return mentorsJson.map((json) => Mentor.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load mentors');
  }

  Future<Mentor> createMentor(Map<String, dynamic> mentorData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mentors'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(mentorData),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Mentor.fromJson(data['data']);
      }
    }
    throw Exception('Failed to create mentor: ${response.body}');
  }

  Future<void> updateMentor(String id, Map<String, dynamic> updates, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/mentors/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update mentor: ${response.body}');
    }
  }

  Future<void> deleteMentor(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/mentors/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete mentor');
    }
  }

  // --- Projects ---

  Future<List<Project>> getProjects() async {
    final response = await http.get(Uri.parse('$baseUrl/projects'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> projectsJson = data['projects'];
        return projectsJson.map((json) => Project.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load projects');
  }

  Future<Project> getFeaturedProject() async {
    final response = await http.get(Uri.parse('$baseUrl/projects/featured'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['project'] != null) {
        return Project.fromJson(data['project']);
      }
    }
    throw Exception('Failed to load featured project');
  }

  Future<Project> createProject(Map<String, dynamic> projectData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(projectData),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Project.fromJson(data['project']);
      }
    }
    throw Exception('Failed to create project');
  }

  Future<void> updateProject(String id, Map<String, dynamic> updates, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/projects/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update project');
    }
  }

  Future<void> deleteProject(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete project');
    }
  }

  // --- Updates ---

  Future<List<AppUpdate>> getUpdates() async {
    final response = await http.get(Uri.parse('$baseUrl/updates'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> updatesJson = data['updates'];
        return updatesJson.map((json) => AppUpdate.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load updates');
  }

  Future<List<AppUpdate>> getAllUpdatesAdmin(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/updates/admin'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> updatesJson = data['updates'];
        return updatesJson.map((json) => AppUpdate.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load updates for admin');
  }

  Future<AppUpdate> createUpdate(Map<String, dynamic> updateData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/updates'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updateData),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return AppUpdate.fromJson(data['update']);
      }
    }
    throw Exception('Failed to create update');
  }

  Future<void> updateAppUpdate(String id, Map<String, dynamic> updates, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updates/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to modify update');
    }
  }

  Future<void> deleteUpdate(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/updates/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete update');
    }
  }

  // --- Challenges ---

  Future<List<Challenge>> getChallenges() async {
    final response = await http.get(Uri.parse('$baseUrl/challenges'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> challengesJson = data['data'];
        return challengesJson.map((json) => Challenge.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load challenges');
  }

  Future<Challenge> createChallenge(Map<String, dynamic> challengeData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/challenges'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(challengeData),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Challenge.fromJson(data['data']);
      }
    }
    throw Exception('Failed to create challenge: ${response.body}');
  }

  Future<void> updateChallenge(String id, Map<String, dynamic> updates, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/challenges/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update challenge: ${response.body}');
    }
  }

  Future<void> deleteChallenge(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/challenges/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete challenge');
    }
  }

  // --- Testimonials ---

  Future<List<Testimonial>> getTestimonials() async {
    final response = await http.get(Uri.parse('$baseUrl/testimonials'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> testimonialsJson = data['data'];
        return testimonialsJson.map((json) => Testimonial.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load testimonials');
  }

  Future<Testimonial> createTestimonial(Map<String, dynamic> testimonialData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/testimonials'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(testimonialData),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Testimonial.fromJson(data['data']);
      }
    }
    throw Exception('Failed to create testimonial: ${response.body}');
  }

  Future<void> updateTestimonial(String id, Map<String, dynamic> updates, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/testimonials/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update testimonial: ${response.body}');
    }
  }

  Future<void> deleteTestimonial(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/testimonials/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete testimonial');
    }
  }

  // --- Inquiries ---

  Future<void> createInquiry(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inquiries'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to submit inquiry: ${response.body}');
    }
  }

  Future<List<Inquiry>> getInquiries(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/inquiries'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List<dynamic> inquiriesJson = data['inquiries'];
        return inquiriesJson.map((json) => Inquiry.fromJson(json)).toList();
      }
    }
    throw Exception('Failed to load inquiries: ${response.body}');
  }

  Future<void> updateInquiryStatus(String id, String status, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/inquiries/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update inquiry: ${response.body}');
    }
  }

  Future<void> deleteInquiry(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/inquiries/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete inquiry');
    }
  }

  // --- About Us ---
  Future<Map<String, dynamic>?> getAboutUs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/about'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateAboutUs(Map<String, dynamic> data) async {
    final token = await AuthService().getIdToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/about'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception('Failed to update About Us: $e');
    }
  }

  Future<Map<String, dynamic>?> getTechnology() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/technology'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateTechnology(Map<String, dynamic> data) async {
    final token = await AuthService().getIdToken();
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/technology'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception('Failed to update Technology: $e');
    }
  }
  
  // --- Services ---
  Future<List<Service>> getServices() async {
    final response = await http.get(Uri.parse('$baseUrl/services'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Service.fromJson(json)).toList();
    }
    throw Exception('Failed to load services');
  }

  Future<Service> createService(Map<String, dynamic> data) async {
    final token = await AuthService().getIdToken();
    final response = await http.post(
      Uri.parse('$baseUrl/services'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return Service.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create service: ${response.body}');
  }

  Future<void> updateService(String id, Map<String, dynamic> data) async {
    final token = await AuthService().getIdToken();
    final response = await http.put(
      Uri.parse('$baseUrl/services/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update service: ${response.body}');
    }
  }

  Future<void> deleteService(String id) async {
    final token = await AuthService().getIdToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/services/$id'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete service');
    }
  }
}
