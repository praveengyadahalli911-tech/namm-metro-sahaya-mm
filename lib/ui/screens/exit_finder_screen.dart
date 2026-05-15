import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/exit_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../data/models/exit_gate_model.dart';

/// Exit Finder Screen — UC-NMS-03: Finding the right gate.
/// Overhauled with premium high-fidelity UI.
class ExitFinderScreen extends StatefulWidget {
  final String? prefilledStationId;
  final String? prefilledStationName;

  const ExitFinderScreen({
    super.key,
    this.prefilledStationId,
    this.prefilledStationName,
  });

  @override
  State<ExitFinderScreen> createState() => _ExitFinderScreenState();
}

class _ExitFinderScreenState extends State<ExitFinderScreen> {
  final TextEditingController _landmarkCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ExitViewModel>();
      if (widget.prefilledStationId != null) {
        vm.setStation(widget.prefilledStationId!, widget.prefilledStationName ?? '');
      }
    });
  }

  @override
  void dispose() {
    _landmarkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exitVM = context.watch<ExitViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isKannada ? 'ನಿರ್ಗಮನ ದ್ವಾರ' : 'Exit Finder',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 110, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStationInfo(exitVM, isKannada),
            const SizedBox(height: 32),
            _buildSearchSection(exitVM, isKannada),
            const SizedBox(height: 32),
            _buildResults(exitVM, isKannada),
          ],
        ),
      ),
    );
  }

  Widget _buildStationInfo(ExitViewModel vm, bool isKannada) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accentBlue]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.place_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isKannada ? 'ಪ್ರಸ್ತುತ ನಿಲ್ದಾಣ' : 'Current Station', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(vm.currentStationName.isEmpty ? (isKannada ? 'ಆಯ್ಕೆ ಮಾಡಲಾಗಿಲ್ಲ' : 'Not Selected') : vm.currentStationName, 
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(ExitViewModel vm, bool isKannada) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isKannada ? 'ನೀವೂ ಎಲ್ಲಿಗೆ ಹೋಗಬೇಕು?' : 'Where are you heading?', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: _landmarkCtrl,
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => vm.searchLandmarks(v),
            decoration: InputDecoration(
              hintText: isKannada ? 'ಉದಾ: ಮೆಜೆಸ್ಟಿಕ್ ಬಸ್ ನಿಲ್ದಾಣ' : 'e.g. Majestic Bus Stand',
              hintStyle: const TextStyle(color: AppColors.textDim),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults(ExitViewModel vm, bool isKannada) {
    if (vm.gates.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(isKannada ? 'ನಿಮ್ಮ ಸ್ಥಳ ಹುಡುಕಿ' : 'Search for a landmark', style: const TextStyle(color: AppColors.textDim)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isKannada ? 'ಸೂಕ್ತ ದ್ವಾರಗಳು' : 'Recommended Gates', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        ...vm.gates.map((gate) => _buildGateCard(gate, isKannada)),
      ],
    );
  }

  Widget _buildGateCard(ExitGate gate, bool isKannada) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '${gate.gateNumber}',
                      style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isKannada ? 'ದ್ವಾರ ಸಂಖ್ಯೆ' : 'Gate Number', style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
                      Text(gate.directionLabel, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(gate.landmarks.join(', '), style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
