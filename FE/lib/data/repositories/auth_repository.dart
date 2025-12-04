import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post(AppConstants.loginEndpoint, {
        'username': username,
        'password': password,
      });

      if (response['token'] != null) {
        await _apiService.setToken(response['token']);

        // Save user data
        saveUserData(response);
      }

      return response;
    } catch (e) {
      final message = e.toString();
      if (message.contains('Unauthorized')) {
        throw Exception('Username or password incorrect');
      }
      throw Exception('Login failed: $message');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post(
        AppConstants.registerEndpoint,
        userData,
      );

      if (response['token'] != null) {
        await _apiService.setToken(response['token']);

        // Save user data
        saveUserData(response);
      }

      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<Map<String, dynamic>> registerStudentForInstructor(
      Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post(
        '/auth/register-student',
        userData,
      );
      // Do NOT change current token or saved user data here.
      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  void saveUserData(Map<String, dynamic> response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.userDataKey,
        jsonEncode(response['customer']),
      );
      await prefs.setString(
        AppConstants.userRoleKey,
        response['customer']['role'],
      );
      await prefs.setInt(
        AppConstants.userIdKey,
        response['customer']['customerID'],
      );
      await prefs.setString(AppConstants.tokenKey, response['token']);
    } catch (e) {
      throw Exception('Save user data failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.clearToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userDataKey);
      await prefs.remove(AppConstants.userRoleKey);
      await prefs.remove(AppConstants.userIdKey);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConstants.userDataKey);

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey) != null;
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userRoleKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.userIdKey);
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(
      prefs.getString(AppConstants.userDataKey) ?? '{}',
    );
    return userData;
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> userData,
  ) async {
    try {
      final formData = FormData.fromMap({
        'fullname': userData['fullname'],
        'email': userData['email'],
        'phone_number': userData['phone_number'],
        if (userData['avatar'] != null)
          'avatar': await MultipartFile.fromFile(
              userData['avatar'].path,
              filename: userData['avatar'].path.split('/').last,
          ),
      });

      final response = await _apiService.dioPatch("/customers/${await getUserId()}/profile", formData);

      // Update local user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userDataKey, jsonEncode(response));

      return response;
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.patch(
        "/auth/${await getUserId()}/change-password",
        {'current_password': currentPassword, 'new_password': newPassword},
      );
      return response;
    } catch (e) {
      throw Exception('Change password failed: $e');
    }
  }
}
