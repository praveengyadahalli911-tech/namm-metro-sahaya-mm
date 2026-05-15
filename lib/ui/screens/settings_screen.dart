import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../core/utils/security_utils.dart'; // CVE-2 fix
import 'admin_panel_screen.dart';

/// Settings Screen (UC-NMS-05): Language toggle + admin mode
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          isKannada ? 'ಸೆಟ್ಟಿಂಗ್ಸ್' : 'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 110, 20, 40),
        children: [
          // Language section
          _buildSectionHeader(isKannada ? 'ಭಾಷೆ' : 'Language', Icons.language_rounded, isKannada),
          const SizedBox(height: 16),
          _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKannada ? 'ಅಪ್ಲಿಕೇಶನ್ ಭಾಷೆ ಆಯ್ಕೆ ಮಾಡಿ' : 'Select application language',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textDim),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _LanguageOption(
                        label: 'English',
                        sublabel: 'English',
                        isSelected: !isKannada,
                        onTap: () => settings.setLanguage('en'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LanguageOption(
                        label: 'ಕನ್ನಡ',
                        sublabel: 'Kannada',
                        isSelected: isKannada,
                        onTap: () => settings.setLanguage('kn'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Cache status
          _buildSectionHeader(isKannada ? 'ಡೇಟಾ ಕ್ಯಾಶ್' : 'Data Cache', Icons.storage_rounded, isKannada),
          const SizedBox(height: 16),
          _buildGlassCard(
            child: Column(
              children: [
                _buildCacheRow(isKannada ? 'ನಿಲ್ದಾಣ ಡೇಟಾ' : 'Station Data', isKannada ? 'ಕ್ಯಾಶ್ ಮಾಡಲಾಗಿದೆ' : 'Cached', Icons.check_circle_rounded, AppColors.accent),
                const Divider(color: Colors.white10, height: 24),
                _buildCacheRow(isKannada ? 'ಮಾರ್ಗ ಗ್ರಾಫ್' : 'Route Graph', isKannada ? 'ಕ್ಯಾಶ್ ಮಾಡಲಾಗಿದೆ' : 'Cached', Icons.check_circle_rounded, AppColors.accent),
                const Divider(color: Colors.white10, height: 24),
                _buildCacheRow(isKannada ? 'ನಿರ್ಗಮನ ದ್ವಾರ ಡೇಟಾ' : 'Exit Gate Data', isKannada ? 'ಕ್ಯಾಶ್ ಮಾಡಲಾಗಿದೆ' : 'Cached', Icons.check_circle_rounded, AppColors.accent),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Admin section
          _buildSectionHeader(isKannada ? 'ಆಡಳಿತ' : 'Administration', Icons.admin_panel_settings_rounded, isKannada),
          const SizedBox(height: 16),
          _buildGlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isKannada ? 'ಆಡಳಿತ ಮೋಡ್' : 'Admin Mode', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(isKannada ? 'ಉದ್ಯೋಗಿಗಳಿಗೆ ಮಾತ್ರ' : 'For employees only', style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
                        ],
                      ),
                    ),
                    Switch(
                      value: settings.isAdmin,
                      activeColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                      inactiveThumbColor: Colors.white54,
                      inactiveTrackColor: Colors.white10,
                      onChanged: (val) async {
                        if (val) {
                          final pinCtrl = TextEditingController();
                          final granted = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text('Admin PIN Required', style: TextStyle(color: Colors.white)),
                              content: TextField(
                                controller: pinCtrl,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(hintText: '1234', hintStyle: TextStyle(color: Colors.white24)),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, pinCtrl.text == '1234'), child: const Text('Verify')),
                              ],
                            ),
                          );
                          if (granted == true) settings.setAdminMode(true);
                        } else {
                          settings.setAdminMode(false);
                        }
                      },
                    ),
                  ],
                ),
                if (settings.isAdmin) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => showAdminPinGate(context, const AdminPanelScreen()),
                      icon: const Icon(Icons.dashboard_customize_rounded),
                      label: Text(isKannada ? 'ಆಡಳಿತ ಫಲಕ ತೆರೆಯಿರಿ' : 'Open Admin Panel', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 40),

          // App info
          Center(
            child: Column(
              children: [
                Text('Namma Metro Sahaya v1.0.0', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white38)),
                const SizedBox(height: 4),
                const Text('SRD-NMS-001 | MindMatrix VTU Internship', style: TextStyle(fontSize: 11, color: Colors.white24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isKannada) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildCacheRow(String label, String status, IconData icon, Color color) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500))),
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(status, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({required this.label, required this.sublabel, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1), width: 1),
          boxShadow: [if (isSelected) BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(sublabel, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : AppColors.textDim)),
          ],
        ),
      ),
    );
  }
}
