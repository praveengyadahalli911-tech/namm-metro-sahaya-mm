import 'package:flutter/material.dart';
import '../data/models/feedback_model.dart';
import '../data/repositories/feedback_repository.dart';

enum FeedbackState { idle, submitting, success, error }

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository _repo;

  FeedbackViewModel(this._repo);

  // ── Form state ────────────────────────────────────────────────────────────
  int _rating = 0;
  String _category = 'general';
  String _message = '';
  String _stationName = '';
  bool _isAnonymous = true;

  // ── Submit state ──────────────────────────────────────────────────────────
  FeedbackState _state = FeedbackState.idle;
  FeedbackEntry? _lastSubmitted;
  String _errorMessage = '';

  // ── Getters ───────────────────────────────────────────────────────────────
  int get rating => _rating;
  String get category => _category;
  String get message => _message;
  String get stationName => _stationName;
  bool get isAnonymous => _isAnonymous;
  FeedbackState get state => _state;
  FeedbackEntry? get lastSubmitted => _lastSubmitted;
  String get errorMessage => _errorMessage;

  // All submitted entries (for history / admin view)
  List<FeedbackEntry> get allEntries => _repo.all;
  double get averageRating => _repo.averageRating;
  int get totalCount => _repo.count;
  Map<int, int> get ratingDistribution => _repo.ratingDistribution;

  // ── Setters ───────────────────────────────────────────────────────────────
  void setRating(int r) {
    _rating = r;
    notifyListeners();
  }

  void setCategory(String c) {
    _category = c;
    notifyListeners();
  }

  void setMessage(String m) {
    _message = m;
    notifyListeners();
  }

  void setStationName(String s) {
    _stationName = s;
    notifyListeners();
  }

  void setAnonymous(bool val) {
    _isAnonymous = val;
    notifyListeners();
  }

  bool get isValid => _rating > 0 && _message.trim().length >= 5;

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> submit() async {
    if (!isValid) {
      _errorMessage = 'Please select a rating and write a short message.';
      _state = FeedbackState.error;
      notifyListeners();
      return;
    }

    _state = FeedbackState.submitting;
    notifyListeners();

    try {
      _lastSubmitted = await _repo.submit(
        rating: _rating,
        category: _category,
        message: _message.trim(),
        stationName: _stationName,
        isAnonymous: _isAnonymous,
      );
      _state = FeedbackState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = FeedbackState.error;
    }
    notifyListeners();
  }

  // ── Reset form for another submission ─────────────────────────────────────
  void reset() {
    _rating = 0;
    _category = 'general';
    _message = '';
    _stationName = '';
    _isAnonymous = true;
    _state = FeedbackState.idle;
    _lastSubmitted = null;
    _errorMessage = '';
    notifyListeners();
  }

  // ── Admin: delete entry ───────────────────────────────────────────────────
  void deleteEntry(String id) {
    _repo.delete(id);
    notifyListeners();
  }
}
