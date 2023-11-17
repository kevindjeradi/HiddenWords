// api.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hidden_words_front/helpers/logger.dart';
import 'package:hidden_words_front/services/token_service.dart';
import 'package:http/http.dart' as http;

class Api {
  static final TokenService _tokenService = TokenService();
  static final String baseUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:3000';

  Future<http.Response> _handleRequest(
      Future<http.Response> Function() action) async {
    try {
      final response = await action();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        Log.logger.e('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to complete request');
      }
    } catch (e, s) {
      Log.logger.e('Error: $e\nStack trace: $s');
      throw Exception('Failed to complete request');
    }
  }

  Future<http.Response> get(String url) async {
    final token = await _tokenService.getToken() ?? 'Token vide';
    return _handleRequest(() => http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
  }

  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    final token = await _tokenService.getToken() ?? 'Token vide';
    return _handleRequest(() => http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        ));
  }

  Future<http.Response> put(String url, Map<String, dynamic> data) async {
    final token = await _tokenService.getToken() ?? 'Token vide';
    return _handleRequest(() => http.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        ));
  }

  Future<http.Response> patch(String url, Map<String, dynamic> data) async {
    final token = await _tokenService.getToken() ?? 'Token vide';
    return _handleRequest(() => http.patch(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        ));
  }

  Future<http.Response> delete(String url) async {
    final token = await _tokenService.getToken() ?? 'Token vide';
    return _handleRequest(() => http.delete(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
  }
}
