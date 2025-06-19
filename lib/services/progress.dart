import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'supabase.dart';

class ProgressService {
  static const String _progressKey = 'lesson_progress';
  static const String _sectionProgressKey = 'section_progress';

  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;
  final SupabaseService _supabaseService = SupabaseService();
  String? _userId;

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();

      _userId = _prefs.getString('user_id');
      if (_userId == null) {
        _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        await _prefs.setString('user_id', _userId!);
      }

      _initialized = true;
      print('✅ ProgressService initialized for user: $_userId');
      _syncFromCloud();
    }
  }

  Future<void> markLessonCompleted(String technologyId, String sectionId, String lessonId) async {
    final key = '${technologyId}_${sectionId}_${lessonId}';
    await _prefs.setBool(key, true);

    await _updateSectionProgress(technologyId, sectionId);
    _syncToCloud();
  }

  bool isLessonCompleted(String technologyId, String sectionId, String lessonId) {
    final key = '${technologyId}_${sectionId}_${lessonId}';
    final completed = _prefs.getBool(key) ?? false;
    return completed;
  }

  Future<void> _updateSectionProgress(String technologyId, String sectionId) async {
    final totalLessons = _getTotalLessonsForSection(technologyId, sectionId);
    int completedLessons = 0;

    for (int i = 1; i <= totalLessons; i++) {
      final lessonId = 'lesson_$i';
      if (isLessonCompleted(technologyId, sectionId, lessonId)) {
        completedLessons++;
      }
    }

    final sectionKey = '${technologyId}_${sectionId}_progress';
    await _prefs.setInt(sectionKey, completedLessons);
  }

  Future<void> setSectionProgress(String technologyId, String sectionId, int completedLessons) async {
    final sectionKey = '${technologyId}_${sectionId}_progress';
    await _prefs.setInt(sectionKey, completedLessons);
  }

  int getSectionProgress(String technologyId, String sectionId) {
    final sectionKey = '${technologyId}_${sectionId}_progress';
    final progress = _prefs.getInt(sectionKey) ?? 0;
    return progress;
  }

  Future<void> markSectionTestCompleted(String technologyId, String sectionId, bool passed) async {
    final key = '${technologyId}_${sectionId}_test_completed';
    await _prefs.setBool(key, passed);

    _syncToCloud();
  }

  bool isSectionTestCompleted(String technologyId, String sectionId) {
    final key = '${technologyId}_${sectionId}_test_completed';
    final completed = _prefs.getBool(key) ?? false;
    return completed;
  }

  int _getTotalLessonsForSection(String technologyId, String sectionId) {
    if (technologyId == 'css' && sectionId == 'css-flexbox') {
      return 2;
    }
    return 5;
  }

  Future<void> resetAllProgress() async {
    final keys = _prefs.getKeys();
    for (String key in keys) {
      if (key.contains('_lesson_') || key.contains('_progress') || key.contains('_test_')  || key.contains('_technology_')) {
        await _prefs.remove(key);
      }
    }
  }

  Future<void> unlockSection(String technologyId, String sectionId) async {
    final key = 'unlocked_${technologyId}_${sectionId}';
    await _prefs.setBool(key, true);
  }

  bool isSectionUnlockedByProgress(String technologyId, String sectionId) {
    final key = 'unlocked_${technologyId}_${sectionId}';
    return _prefs.getBool(key) ?? false;
  }

  Future<void> unlockTechnology(String technologyId) async {
    final key = 'unlocked_technology_${technologyId}';
    await _prefs.setBool(key, true);
  }

  bool isTechnologyUnlockedByProgress(String technologyId) {
    final key = 'unlocked_technology_${technologyId}';
    return _prefs.getBool(key) ?? false;
  }

  void _syncToCloud() async {
    if (_userId == null) return;

    try {
      //zbierz wszystkie dane progress
      final Map<String, dynamic> progressData = {};
      final keys = _prefs.getKeys();

      for (String key in keys) {
        if (key.contains('_lesson_') || key.contains('_progress') || key.contains('_test_')) {
          final value = _prefs.get(key);
          progressData[key] = value;
        }
      }

      //wyślij w tle (nie czekaj na response)
      _supabaseService.syncUserProgress(_userId!, progressData).then((success) {
        if (success) {
          print('Progress synced to cloud');
        }
      });
    } catch (e) {
      print('Background sync failed: $e');
    }

  }

  void _syncFromCloud() async {
    if (_userId == null) return;

    try {
      final cloudProgress = await _supabaseService.getUserProgress(_userId!);
      if (cloudProgress != null) {
        //merge cloud data z local data (cloud wins dla nowszych danych)
        bool hasUpdates = false;

        cloudProgress.forEach((key, value) async {
          if (!_prefs.containsKey(key)) {
            if (value is bool) {
              await _prefs.setBool(key, value);
              hasUpdates = true;
            } else if (value is int) {
              await _prefs.setInt(key, value);
              hasUpdates = true;
            }
          }
        });

        if (hasUpdates) {
          print('Progress updated from cloud');
        }
      }
    } catch (e) {
      print('Cloud sync failed: $e');
    }
  }

  Future<void> submitQuizResult({
    required String technologyId,
    required String sectionId,
    required int score,
    required int totalQuestions,
    required Duration timeTaken,
  }) async {
    if (_userId == null) return;

    _supabaseService.submitQuizResult(
      userId: _userId!,
      technologyId: technologyId,
      sectionId: sectionId,
      score: score,
      totalQuestions: totalQuestions,
      timeTaken: timeTaken,
    ).then((success) {
      if (success) {
        print('Quiz analytics submitted');
      }
    });
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    return await _supabaseService.getLeaderboard();
  }

  Future<bool> forceSyncToCloud() async {
    if (_userId == null) return false;

    final Map<String, dynamic> progressData = {};
    final keys = _prefs.getKeys();

    for (String key in keys) {
      if (key.contains('_lesson_') || key.contains('_progress') || key.contains('_test_')) {
        final value = _prefs.get(key);
        progressData[key] = value;
      }
    }

    final success = await _supabaseService.syncUserProgress(_userId!, progressData);
    if (success) {
      print('Manual sync completed');
    }
    return success;
  }

}

