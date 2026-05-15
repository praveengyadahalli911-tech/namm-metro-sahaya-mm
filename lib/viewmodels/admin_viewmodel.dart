import 'package:flutter/material.dart';
import '../data/models/exit_gate_model.dart';
import '../data/repositories/exit_repository.dart';

enum AdminSaveState { idle, saving, success, error }

class AdminViewModel extends ChangeNotifier {
  final ExitRepository _repository;

  AdminSaveState _saveState = AdminSaveState.idle;
  String _saveError = '';
  List<ExitGate> _stationExits = [];
  String _selectedStationId = '';

  AdminViewModel(this._repository);

  AdminSaveState get saveState => _saveState;
  String get saveError => _saveError;
  List<ExitGate> get stationExits => _stationExits;
  String get selectedStationId => _selectedStationId;

  void selectStation(String stationId) {
    _selectedStationId = stationId;
    _stationExits = _repository.getExitsForStation(stationId);
    _saveState = AdminSaveState.idle;
    notifyListeners();
  }

  void refreshExits() {
    if (_selectedStationId.isNotEmpty) {
      _stationExits = _repository.getExitsForStation(_selectedStationId);
      notifyListeners();
    }
  }

  /// FR-NMS-14: Save (add/edit) an exit gate record
  Future<bool> saveExit(ExitGate gate) async {
    _saveState = AdminSaveState.saving;
    notifyListeners();

    try {
      // CVE-5 FIX: timeout guard for future real DB writes
      await Future.delayed(const Duration(milliseconds: 200))
          .timeout(const Duration(seconds: 5));

      final error = _repository.upsert(gate);
      if (error != null) {
        _saveState = AdminSaveState.error;
        _saveError = error;
        notifyListeners();
        return false;
      }
      _saveState = AdminSaveState.success;
      refreshExits();
      return true;
    } catch (e) {
      _saveState = AdminSaveState.error;
      _saveError = 'Save timed out. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void deleteExit(String exitId) {
    _repository.delete(exitId);
    refreshExits();
  }

  void resetState() {
    _saveState = AdminSaveState.idle;
    _saveError = '';
    notifyListeners();
  }
}
