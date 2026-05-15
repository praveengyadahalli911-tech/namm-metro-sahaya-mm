import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../data/models/metro_models.dart';

/// UC-NMS-09: Bus/Auto Multi-Modal Connectivity (Last-Mile)
/// Displays connecting transit options outside a given station.
/// Data is simulated since we are offline-first.
class LastMileScreen extends StatelessWidget {
  final Station station;

  const LastMileScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isKannada ? 'ಕೊನೆಯ ಮೈಲಿ ಸಂಪರ್ಕ' : 'Last Mile Connectivity',
          style: GoogleFonts.notoSansKannada(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withAlpha(200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.transfer_within_a_station,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isKannada ? 'ನಿಲ್ದಾಣ:' : 'Station:',
                          style: GoogleFonts.notoSansKannada(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    station.name,
                    style: GoogleFonts.notoSansKannada(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isKannada
                        ? 'ಮೆಟ್ರೋದಿಂದ ನಿಮ್ಮ ಗಮ್ಯಸ್ಥಾನಕ್ಕೆ ಸುಲಭ ಸಂಪರ್ಕ'
                        : 'Seamless transit from metro to your final destination',
                    style: GoogleFonts.notoSansKannada(
                      color: Colors.white.withAlpha(220),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bus Feeder Section
            _buildSectionHeader(
              context,
              title: isKannada ? 'ಬಿಎಂಟಿಸಿ ಫೀಡರ್ ಬಸ್‌ಗಳು' : 'BMTC Feeder Buses',
              icon: Icons.directions_bus,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildTransitCard(
              context,
              route: 'MF-1',
              destination: isKannada ? 'ಸಿಲ್ಕ್ ಬೋರ್ಡ್' : 'Silk Board',
              distance: '2 min walk',
              frequency: isKannada ? 'ಪ್ರತಿ 15 ನಿಮಿಷಕ್ಕೆ' : 'Every 15 mins',
              color: Colors.orange,
            ),
            _buildTransitCard(
              context,
              route: 'MF-2',
              destination: isKannada ? 'ಮೈಕೋ ಲೇಔಟ್' : 'Mico Layout',
              distance: '3 min walk',
              frequency: isKannada ? 'ಪ್ರತಿ 20 ನಿಮಿಷಕ್ಕೆ' : 'Every 20 mins',
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            // Auto Stand Section
            _buildSectionHeader(
              context,
              title: isKannada ? 'ಆಟೋ ನಿಲ್ದಾಣಗಳು' : 'Auto Rickshaw Stands',
              icon: Icons.local_taxi,
              iconColor: Colors.amber[700]!,
            ),
            const SizedBox(height: 12),
            _buildTransitCard(
              context,
              route: 'Prepaid',
              destination: isKannada ? 'ಗೇಟ್ ಎ ಬಳಿ' : 'Near Gate A',
              distance: '1 min walk',
              frequency: isKannada ? '24/7 ಲಭ್ಯವಿದೆ' : 'Available 24/7',
              color: Colors.amber[700]!,
              isAuto: true,
            ),

            const SizedBox(height: 24),

            // Bike Share Section
            _buildSectionHeader(
              context,
              title: isKannada ? 'ಬೈಕ್ ಹಂಚಿಕೆ / ಬಾಡಿಗೆ' : 'Bike Share / Rentals',
              icon: Icons.pedal_bike,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildTransitCard(
              context,
              route: 'Yulu',
              destination: isKannada ? 'ಪಾರ್ಕಿಂಗ್ ಲಾಟ್' : 'Parking Lot',
              distance: '1 min walk',
              frequency: isKannada ? 'ಆಪ್ ಮೂಲಕ ಬಳಸಿ' : 'Use via App',
              color: Colors.green,
              isBike: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      {required String title, required IconData icon, required Color iconColor}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.notoSansKannada(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTransitCard(
    BuildContext context, {
    required String route,
    required String destination,
    required String distance,
    required String frequency,
    required Color color,
    bool isAuto = false,
    bool isBike = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withAlpha(80)),
              ),
              child: Text(
                route,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination,
                    style: GoogleFonts.notoSansKannada(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.directions_walk,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        distance,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(isAuto ? Icons.timer : isBike ? Icons.smartphone : Icons.schedule,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        frequency,
                        style: GoogleFonts.notoSansKannada(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
