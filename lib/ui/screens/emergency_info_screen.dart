import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

/// UC-NMS-14: Security Hotlines & Emergency Info
/// Provides quick access to critical contact numbers.
class EmergencyInfoScreen extends StatelessWidget {
  const EmergencyInfoScreen({super.key});

  Future<void> _callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isKannada ? 'ತುರ್ತು ಸಂಪರ್ಕಗಳು' : 'Emergency Info',
          style: GoogleFonts.notoSansKannada(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: AppColors.warning, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isKannada
                          ? 'ತುರ್ತು ಸಂದರ್ಭದಲ್ಲಿ ಮಾತ್ರ ಈ ಸಂಖ್ಯೆಗಳಿಗೆ ಕರೆ ಮಾಡಿ.'
                          : 'Call these numbers only in case of a genuine emergency.',
                      style: GoogleFonts.notoSansKannada(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isKannada ? 'ಮೆಟ್ರೋ ಸಹಾಯವಾಣಿ' : 'Metro Helpline',
              style: GoogleFonts.notoSansKannada(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              context,
              title: isKannada ? 'ಟೋಲ್ ಫ್ರೀ (BMRCL)' : 'Toll Free (BMRCL)',
              number: '1800-425-12345',
              icon: Icons.support_agent,
            ),
            _buildContactCard(
              context,
              title: isKannada ? 'ಭದ್ರತಾ ನಿಯಂತ್ರಣ ಕೊಠಡಿ' : 'Security Control Room',
              number: '080-25191091',
              icon: Icons.security,
            ),
            const SizedBox(height: 24),
            Text(
              isKannada ? 'ರಾಷ್ಟ್ರೀಯ ತುರ್ತು ಸಂಖ್ಯೆಗಳು' : 'National Emergency',
              style: GoogleFonts.notoSansKannada(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              context,
              title: isKannada ? 'ಪೊಲೀಸ್' : 'Police',
              number: '112',
              icon: Icons.local_police,
              isHighPriority: true,
            ),
            _buildContactCard(
              context,
              title: isKannada ? 'ಆಂಬ್ಯುಲೆನ್ಸ್' : 'Ambulance',
              number: '108',
              icon: Icons.medical_services,
              isHighPriority: true,
            ),
            _buildContactCard(
              context,
              title: isKannada ? 'ಮಹಿಳಾ ಸಹಾಯವಾಣಿ' : 'Women Helpline',
              number: '1091',
              icon: Icons.pregnant_woman,
              isHighPriority: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String title,
    required String number,
    required IconData icon,
    bool isHighPriority = false,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _callNumber(number),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isHighPriority ? AppColors.warning : AppColors.primary).withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isHighPriority ? AppColors.warning : AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSansKannada(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isHighPriority ? AppColors.warning : AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.call, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
