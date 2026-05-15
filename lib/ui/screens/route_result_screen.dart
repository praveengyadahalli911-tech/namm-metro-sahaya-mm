import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/route_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../data/models/metro_models.dart';
import 'visual_guide_screen.dart';
import 'exit_finder_screen.dart';
import 'feedback_screen.dart';

/// Route Result Screen — UC-NMS-01: Journey Details
/// Overhauled to match high-fidelity premium mockups.
class RouteResultScreen extends StatelessWidget {
  const RouteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routeVM = context.watch<RouteViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';
    final route = routeVM.currentRoute;

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
          isKannada ? 'ಪ್ರಯಾಣದ ವಿವರ' : 'Journey Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: route.isEmpty
          ? _buildEmptyState(isKannada)
          : Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 100),
                    // ── Sticky summary header ────────────────────────────
                    _buildPremiumHeader(context, routeVM, isKannada),
                    // ── Stop list ────────────────────────────────────────
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        itemCount: route.length,
                        itemBuilder: (context, index) {
                          final station = route[index];
                          final isFirst = index == 0;
                          final isLast = index == route.length - 1;
                          return _buildPremiumStopRow(
                              station, isFirst, isLast, isKannada);
                        },
                      ),
                    ),
                  ],
                ),
                // ── Action buttons ───────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildPremiumActionButtons(context, routeVM, isKannada),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(bool isKannada) {
    return Center(
      child: Text(
        isKannada ? 'ಯಾವುದೇ ಮಾರ್ಗವಿಲ್ಲ' : 'No route found',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, RouteViewModel vm, bool isKannada) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(Icons.timer_outlined, '${vm.estimatedTimeMins} min', isKannada ? 'ಸಮಯ' : 'Time'),
                Container(width: 1, height: 40, color: Colors.white12),
                _buildHeaderStat(Icons.directions_walk_rounded, '${vm.totalDistanceKm.toStringAsFixed(1)} km', isKannada ? 'ದೂರ' : 'Distance'),
                Container(width: 1, height: 40, color: Colors.white12),
                _buildHeaderStat(Icons.currency_rupee_rounded, '₹${vm.totalFare}', isKannada ? 'ದರ' : 'Fare'),
                Container(width: 1, height: 40, color: Colors.white12),
                _buildHeaderStat(Icons.directions_subway_rounded, '${vm.currentRoute.length}', isKannada ? 'ನಿಲ್ದಾಣಗಳು' : 'Stops'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
      ],
    );
  }

  Widget _buildPremiumStopRow(Station station, bool isFirst, bool isLast, bool isKannada) {
    final color = station.lineId.toLowerCase() == 'purple' ? AppColors.purpleLine : AppColors.greenLine;
    return IntrinsicHeight(
      child: Row(
        children: [
          const SizedBox(width: 20),
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirst || isLast ? color : AppColors.background,
                  border: Border.all(color: color, width: 3),
                  boxShadow: [
                    if (isFirst || isLast) BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 3, color: color.withValues(alpha: 0.3)),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: GoogleFonts.poppins(
                      fontWeight: isFirst || isLast ? FontWeight.bold : FontWeight.w500,
                      fontSize: isFirst || isLast ? 17 : 15,
                      color: isFirst || isLast ? Colors.white : Colors.white70,
                    ),
                  ),
                  if (station.isInterchange)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        isKannada ? 'ಬದಲಾವಣೆ (Interchange)' : 'Change Line Here',
                        style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumActionButtons(BuildContext context, RouteViewModel vm, bool isKannada) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.95)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.map_outlined,
                label: isKannada ? 'ನಕ್ಷೆ' : 'Map',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualGuideScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.door_front_door_outlined,
                label: isKannada ? 'ನಿರ್ಗಮನ' : 'Exit',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExitFinderScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.feedback_outlined,
                label: isKannada ? 'ಪ್ರತಿಕ್ರಿಯೆ' : 'Feedback',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(height: 4),
                Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
