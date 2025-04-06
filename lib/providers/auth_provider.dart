import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, authenticating, error }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  
  AuthStatus _status = AuthStatus.initial;
  String? _token;
  String? _email;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get token => _token;
  String? get email => _email;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    // Check if user is already logged in
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      final userInfo = await _storageService.getUserInfo();
      
      if (token != null) {
        _token = token;
        _email = userInfo['email'];
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  Future<bool> register(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.register(email, password);
      
      if (response.containsKey('token')) {
        _token = response['token'];
        _email = email;
        
        // Store auth data
        await _storageService.storeToken(_token!);
        await _storageService.storeUserInfo(email: email);
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid registration response';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      if (response.containsKey('token')) {
        _token = response['token'];
        _email = email;
        
        // Store auth data
        await _storageService.storeToken(_token!);
        await _storageService.storeUserInfo(email: email);
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Invalid login response';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _token = null;
    _email = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}