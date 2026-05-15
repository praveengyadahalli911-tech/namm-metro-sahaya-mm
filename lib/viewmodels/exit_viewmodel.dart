import 'package:flutter/material.dart';
import '../data/models/exit_gate_model.dart';
import '../data/repositories/exit_repository.dart';

enum ExitSearchState { idle, loading, found, notFound, error }

class ExitViewModel extends ChangeNotifier {
  final ExitRepository _repository;

  ExitSearchState _state = ExitSearchState.idle;
  List<ExitGate> _results = [];
  String _errorMessage = '';
  String _currentStationId = '';
  String _currentStationName = '';

  ExitViewModel(this._repository);

  ExitSearchState get state => _state;
  List<ExitGate> get results => _results;
  String get errorMessage => _errorMessage;
  String get currentStationId => _currentStationId;
  String get currentStationName => _currentStationName;
  List<ExitGate> get gates => _results;
  void searchLandmarks(String query) => findByLandmark(query);

  /// Pre-fill destination station from route result
  void setStation(String stationId, String stationName) {
    _currentStationId = stationId;
    _currentStationName = stationName;
    _state = ExitSearchState.idle;
    _results = [];
    notifyListeners();
  }

  /// FR-NMS-06: Find exit gate by landmark (offline, < 1500ms)
  Future<void> findByLandmark(String landmark) async {
    if (landmark.trim().isEmpty) return;

    _state = ExitSearchState.loading;
    _results = [];
    notifyListeners();

    // Simulate DB query (would be Room DB in production)
    await Future.delayed(const Duration(milliseconds: 300));

    final found = _repository.findByLandmark(_currentStationId, landmark);

    if (found.isEmpty) {
      _state = ExitSearchState.notFound;
      _errorMessage =
          "We don't have data for this landmark. Please ask at the Help Desk.";
    } else {
      _state = ExitSearchState.found;
      _results = found;
    }
    notifyListeners();
  }

  /// Get all exits for current station (for admin list)
  List<ExitGate> getExitsForStation(String stationId) {
    return _repository.getExitsForStation(stationId);
  }

  void reset() {
    _state = ExitSearchState.idle;
    _results = [];
    _errorMessage = '';
    notifyListeners();
  }
}
