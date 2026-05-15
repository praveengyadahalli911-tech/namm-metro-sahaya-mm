import 'package:flutter/material.dart';
import '../data/models/metro_models.dart';
import '../data/repositories/route_repository.dart';

/// RouteViewModel — MVVM state for route planning (UC-NMS-01).
///
/// All business logic lives here or in RouteRepository.
/// No Room DAO is called directly (NFR-MAINT-01 / NFR-SCAL-01).
class RouteViewModel extends ChangeNotifier {
  final RouteRepository _repository;

  Station? _source;
  Station? _destination;
  RouteResult? _result;
  bool _isCalculating = false;
  String _errorMessage = '';

  RouteViewModel(this._repository);

  // ── Getters ────────────────────────────────────────────────────────────
  Station? get source => _source;
  Station? get destination => _destination;
  bool get isCalculating => _isCalculating;
  String get errorMessage => _errorMessage;

  /// The ordered list of stations along the computed path
  List<Station> get currentRoute => _result?.stations ?? [];

  /// FR-NMS-02: Fare from FareMatrix
  int get fare => _result?.fare ?? 0;
  int get totalFare => fare;

  /// FR-NMS-01: Estimated travel time = SUM(avg_segment_duration_mins)
  int get estimatedTimeMins => _result?.totalTimeMins ?? 0;
  int get estimatedFare => _result?.fare ?? 0;
  double get totalDistanceKm => _result?.totalDistanceKm ?? 0.0;
  List<Station> get pathStations => _result?.stations ?? [];

  /// FR-NMS-04: Whether the route crosses between Purple and Green lines
  bool get hasInterchange => _result?.hasInterchange ?? false;

  /// FR-NMS-04: The interchange station (e.g. Majestic)
  Station? get interchangeStation => _result?.interchangeStation;

  /// User-visible stop count (excludes internal interchange connector node)
  int get stopCount => _result?.stopCount ?? 0;

  /// True when a successful result is available
  bool get hasRoute => _result != null && (_result?.isValid ?? false);

  /// Full RouteResult (for screens that need detailed info)
  RouteResult? get result => _result;

  // ── All stations (for autocomplete) ────────────────────────────────────
  List<Station> get allStations => _repository.allStations;

  /// Filter stations matching [query] — used by autocomplete widget
  List<Station> searchStations(String query) =>
      _repository.searchStations(query);

  // ── Setters ────────────────────────────────────────────────────────────
  void setSource(Station? station) {
    _source = station;
    _clearResult();
    notifyListeners();
  }

  void setDestination(Station? station) {
    _destination = station;
    _clearResult();
    notifyListeners();
  }

  void swapStations() {
    final tmp = _source;
    _source = _destination;
    _destination = tmp;
    _clearResult();
    notifyListeners();
  }

  // ── Route Calculation ──────────────────────────────────────────────────

  /// FR-NMS-01: Calculate route. NFR-PERF-01: must complete < 2000ms.
  Future<bool> findRoute() async {
    if (_source == null || _destination == null) return false;

    _isCalculating = true;
    _errorMessage = '';
    notifyListeners();

    // Run on IO thread to keep UI responsive (Dispatchers.IO equivalent)
    await Future.microtask(() {
      _result = _repository.computeRoute(_source!.id, _destination!.id);
    });

    _isCalculating = false;

    if (!(_result?.isValid ?? false)) {
      _errorMessage = _result?.errorMessage ?? 'Route calculation failed.';
      _result = null;
    } else {
      _errorMessage = '';
    }

    notifyListeners();
    return _result != null;
  }

  void _clearResult() {
    _result = null;
    _errorMessage = '';
  }

  void clear() {
    _source = null;
    _destination = null;
    _result = null;
    _errorMessage = '';
    notifyListeners();
  }
}
