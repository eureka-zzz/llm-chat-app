import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

class AppProvider with ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];
  List<Message> _messages = [];
  final WebSocketService _webSocketService = WebSocketService();
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  List<User> get users => _users;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  WebSocketService get webSocketService => _webSocketService;

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize app - check for saved user
  Future<void> initializeApp() async {
    setLoading(true);
    
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final username = prefs.getString('username');
    
    if (userId != null && username != null) {
      _currentUser = User(id: userId, username: username, isOnline: true);
      await connectWebSocket();
      await loadUsers();
    }
    
    setLoading(false);
  }

  // Register/Login user
  Future<bool> registerUser(String username) async {
    setLoading(true);
    
    final user = await ApiService.registerUser(username);
    if (user != null) {
      _currentUser = user;
      
      // Save user data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id);
      await prefs.setString('username', user.username);
      
      await connectWebSocket();
      await loadUsers();
      
      setLoading(false);
      notifyListeners();
      return true;
    }
    
    setLoading(false);
    return false;
  }

  // Connect to WebSocket
  Future<void> connectWebSocket() async {
    if (_currentUser != null) {
      _webSocketService.onMessageReceived = (message) {
        _messages.add(message);
        notifyListeners();
      };
      _webSocketService.connect(_currentUser!.id);
    }
  }

  // Load all users
  Future<void> loadUsers() async {
    _users = await ApiService.getUsers();
    notifyListeners();
  }

  // Load messages for a specific chat
  Future<void> loadMessages(int otherUserId) async {
    if (_currentUser != null) {
      _messages = await ApiService.getMessages(_currentUser!.id, otherUserId);
      notifyListeners();
    }
  }

  // Send a message
  void sendMessage(int receiverId, String messageType, String content) {
    if (_currentUser != null) {
      _webSocketService.sendMessage(receiverId, messageType, content);
      
      // Add message to local list immediately for better UX
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        senderId: _currentUser!.id,
        receiverId: receiverId,
        messageType: messageType,
        content: content,
        timestamp: DateTime.now(),
        sender: _currentUser,
      );
      
      _messages.add(message);
      notifyListeners();
    }
  }

  // Upload file and send message
  Future<void> sendFileMessage(int receiverId, String filePath, String messageType) async {
    final uploadedPath = await ApiService.uploadFile(File(filePath));
    if (uploadedPath != null) {
      sendMessage(receiverId, messageType, uploadedPath);
    }
  }

  // Logout user
  Future<void> logout() async {
    _webSocketService.disconnect();
    _currentUser = null;
    _users.clear();
    _messages.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }

  // Get other users (excluding current user)
  List<User> getOtherUsers() {
    if (_currentUser == null) return [];
    return _users.where((user) => user.id != _currentUser!.id).toList();
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }
}
