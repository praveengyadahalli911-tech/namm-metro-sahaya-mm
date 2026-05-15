import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feedback_model.dart';

/// FeedbackRepository: stores and retrieves feedback entries.
/// CVE-6 FIX: Persisted via SharedPreferences — data survives app restarts.
class FeedbackRepository {
  static const _prefKey = 'nms_feedback_v1';

  final List<FeedbackEntry> _entries = [];
  int _idCounter = 1;
  bool _loaded = false;

  FeedbackRepository() {
    _loadFromPrefs();
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final item in list) {
          final m = item as Map<String, dynamic>;
          _entries.add(FeedbackEntry(
            id: m['id'] as String,
            rating: m['rating'] as int,
            category: m['category'] as String,
            message: m['message'] as String,
            stationName: m['stationName'] as String,
            submittedAt: DateTime.parse(m['submittedAt'] as String),
            isAnonymous: m['isAnonymous'] as bool,
          ));
          // restore counter so IDs don't collide
          final n = int.tryParse((m['id'] as String).replaceAll('FB_', ''));
          if (n != null && n >= _idCounter) _idCounter = n + 1;
        }
        if (kDebugMode) debugPrint('📋 FeedbackRepository: loaded ${_entries.length} entries from storage');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ FeedbackRepository: failed to load entries: $e');
    }
    _loaded = true;
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _entries.map((e) => {
        'id': e.id,
        'rating': e.rating,
        'category': e.category,
        // CVE-3 adjacent: truncate message to 2000 chars before persisting
        'message': e.message.length > 2000 ? e.message.substring(0, 2000) : e.message,
        'stationName': e.stationName,
        'submittedAt': e.submittedAt.toIso8601String(),
        'isAnonymous': e.isAnonymous,
      }).toList();
      await prefs.setString(_prefKey, jsonEncode(list));
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ FeedbackRepository: failed to save entries: $e');
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Submit new feedback. Returns the saved entry.
  Future<FeedbackEntry> submit({
    required int rating,
    required String category,
    required String message,
    required String stationName,
    required bool isAnonymous,
  }) async {
    // CVE-3 FIX: sanitize and cap message length
    final safeMessage = message.trim().length > 2000
        ? message.trim().substring(0, 2000)
        : message.trim();
    final safeStation = stationName.trim().length > 100
        ? stationName.trim().substring(0, 100)
        : stationName.trim();

    final entry = FeedbackEntry(
      id: 'FB_${_idCounter++}',
      rating: rating.clamp(1, 5),
      category: category,
      message: safeMessage,
      stationName: safeStation,
      submittedAt: DateTime.now(),
      isAnonymous: isAnonymous,
    );
    _entries.insert(0, entry); // newest first
    await _saveToPrefs();
    return entry;
  }

  /// All entries (newest first)
  List<FeedbackEntry> get all => List.unmodifiable(_entries);

  /// Filter by category
  List<FeedbackEntry> byCategory(String category) =>
      _entries.where((e) => e.category == category).toList();

  /// Average rating across all entries
  double get averageRating {
    if (_entries.isEmpty) return 0.0;
    final sum = _entries.fold<int>(0, (acc, e) => acc + e.rating);
    return sum / _entries.length;
  }

  /// Count per rating level (1–5)
  Map<int, int> get ratingDistribution {
    final map = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final e in _entries) {
      map[e.rating] = (map[e.rating] ?? 0) + 1;
    }
    return map;
  }

  /// Total count
  int get count => _entries.length;

  /// Delete an entry (admin)
  Future<void> delete(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveToPrefs();
  }
}
