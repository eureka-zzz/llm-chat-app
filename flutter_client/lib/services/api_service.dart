import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/message.dart';

class ApiService {
  // Server URL - Update this to your server's address
  static const String baseUrl = 'http://82298cb6fbaf643872.blackbx.ai';
  
  // Register a new user
  static Future<User?> registerUser(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to register user: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // Get all users
  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = jsonDecode(response.body);
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else {
        print('Failed to get users: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Get messages between two users
  static Future<List<Message>> getMessages(int userId1, int userId2) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/$userId1/$userId2'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = jsonDecode(response.body);
        return messagesJson.map((json) => Message.fromJson(json)).toList();
      } else {
        print('Failed to get messages: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Upload a file
  static Future<String?> uploadFile(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(responseBody);
        return responseJson['file_path'];
      } else {
        print('Failed to upload file: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Get file URL
  static String getFileUrl(String fileName) {
    return '$baseUrl/files/$fileName';
  }
}
