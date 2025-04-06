import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

enum UserStatus { initial, loading, loaded, error }

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<User> _users = [];
  User? _selectedUser;
  UserStatus _status = UserStatus.initial;
  String? _errorMessage;
  String _searchQuery = '';

  List<User> get users => _filterUsers();
  User? get selectedUser => _selectedUser;
  UserStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<User> _filterUsers() {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    
    final query = _searchQuery.toLowerCase();
    return _users.where((user) {
      return user.firstName.toLowerCase().contains(query) ||
             user.lastName.toLowerCase().contains(query) ||
             user.email.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchUsers() async {
    _status = UserStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _users = await _apiService.getUsers();
      _status = UserStatus.loaded;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  Future<void> fetchUserById(int id) async {
    _status = UserStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _selectedUser = await _apiService.getUserById(id);
      _status = UserStatus.loaded;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  Future<bool> createUser(User user) async {
    _status = UserStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final newUser = await _apiService.createUser(user);
      _users.add(newUser);
      _status = UserStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    _status = UserStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _apiService.updateUser(user);
      
      // Update user in the local list
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
      }
      
      _status = UserStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    _status = UserStatus.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final success = await _apiService.deleteUser(id);
      
      if (success) {
        _users.removeWhere((user) => user.id == id);
        _status = UserStatus.loaded;
        notifyListeners();
        return true;
      } else {
        throw Exception('Delete operation returned false');
      }
    } catch (e) {
      _status = UserStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}