import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';

  // Store token
  Future<void> storeToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  // Get token
  Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  // Store user info
  Future<void> storeUserInfo({String? userId, String? email}) async {
    if (userId != null) {
      await _storage.write(key: userIdKey, value: userId);
    }
    if (email != null) {
      await _storage.write(key: userEmailKey, value: email);
    }
  }

  // Get user info
  Future<Map<String, String?>> getUserInfo() async {
    final userId = await _storage.read(key: userIdKey);
    final email = await _storage.read(key: userEmailKey);
    
    return {
      'userId': userId,
      'email': email,
    };
  }

  // Clear all stored data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}