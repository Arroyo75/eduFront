import 'dart:convert';
import 'package:http/http.dart' as http;

class SupabaseService {
  static const String supabaseUrl = 'xxxx'; //your url
  static const String supabaseKey = 'xxxx'; //your key

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'apikey': supabaseKey,
    'Authorization': 'Bearer $supabaseKey',
  };

  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  Future<bool> syncUserProgress(String userId, Map<String, dynamic> progressData) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/user_progress'),
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'progress_data': progressData,
          'last_updated': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        print('Progress synced to cloud');
        return true;
      } else {
        print('Sync failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Sync error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProgress(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/user_progress?user_id=eq.$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          print('Progress loaded from cloud');
          return data.first['progress_data'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Load progress error: $e');
    }
    return null;
  }

  Future<bool> submitQuizResult({
    required String userId,
    required String technologyId,
    required String sectionId,
    required int score,
    required int totalQuestions,
    required Duration timeTaken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/quiz_results'),
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'technology_id': technologyId,
          'section_id': sectionId,
          'score': score,
          'total_questions': totalQuestions,
          'time_taken_seconds': timeTaken.inSeconds,
          'passed': score >= (totalQuestions * 0.7).ceil(),
          'submitted_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        print('Quiz result submitted');
        return true;
      }
    } catch (e) {
      print('Submit quiz error: $e');
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse('$supabaseUrl/rest/v1/leaderboard?select=*&order=total_score.desc&limit=10'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Leaderboard loaded');
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Leaderboard error: $e');
    }
    return [];
  }

  Future<bool> updateUserStats(String userId, int totalScore, int completedSections) async {
    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/leaderboard'),
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'total_score': totalScore,
          'completed_sections': completedSections,
          'last_active': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        print('User stats updated');
        return true;
      }
    } catch (e) {
      print('Update stats error: $e');
    }
    return false;
  }
}