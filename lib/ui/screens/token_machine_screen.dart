import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/settings_viewmodel.dart';

/// FR-NMS-05: Token Machine 4-step sub-flow (UC-NMS-02)
/// 4 fixed steps with large Kannada captions. Done → returns to Visual Guide.
class TokenMachineScreen extends StatefulWidget {
  const TokenMachineScreen({super.key});

  @override
  State<TokenMachineScreen> createState() => _TokenMachineScreenState();
}

class _TokenMachineScreenState extends State<TokenMachineScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _anim;
  late Animation<double> _fadeAnim;

  static const _stepsEn = [
    (
      icon: Icons.touch_app,
      title: 'Select Destination',
      body:
          'On the touch screen, find and tap your destination station name. '
              'Use the search function if needed.',
    ),
    (
      icon: Icons.payments,
      title: 'Choose Ticket Type',
      body:
          'Select "Single Journey" token. The fare will be displayed. '
              'Confirm the amount.',
    ),
    (
      icon: Icons.currency_rupee,
      title: 'Insert Money',
      body:
          'Insert coins or notes into the slot below the screen. '
              'Exact change is not required — change will be returned.',
    ),
    (
      icon: Icons.qr_code,
      title: 'Collect Your Token',
      body:
          'Your token will be dispensed from the lower slot. '
              'Pick it up and tap it on the fare gate to enter the platform.',
    ),
  ];

  static const _stepsKn = [
    (
      icon: Icons.touch_app,
      title: 'ಗಮ್ಯಸ್ಥಾನ ಆಯ್ಕೆ ಮಾಡಿ',
      body:
          'ಟಚ್ ಸ್ಕ್ರೀನ್ ಮೇಲೆ ನಿಮ್ಮ ಗಮ್ಯಸ್ಥಾನ ನಿಲ್ದಾಣದ ಹೆಸರು ಹುಡುಕಿ ಮತ್ತು '
              'ಟ್ಯಾಪ್ ಮಾಡಿ. ಅಗತ್ಯವಿದ್ದರೆ ಹುಡುಕಾಟ ಕಾರ್ಯ ಬಳಸಿ.',
    ),
    (
      icon: Icons.payments,
      title: 'ಟಿಕೆಟ್ ಪ್ರಕಾರ ಆಯ್ಕೆ ಮಾಡಿ',
      body:
          '"ಒಂದು ಪ್ರಯಾಣ" ಟೋಕನ್ ಆಯ್ಕೆ ಮಾಡಿ. ದರ ಪ್ರದರ್ಶಿಸಲ್ಪಡುತ್ತದೆ. '
              'ಮೊತ್ತ ದೃಢೀಕರಿಸಿ.',
    ),
    (
      icon: Icons.currency_rupee,
      title: 'ಹಣ ಹಾಕಿ',
      body:
          'ಸ್ಕ್ರೀನ್ ಕೆಳಗಿನ ಸ್ಲಾಟ್‌ನಲ್ಲಿ ನಾಣ್ಯ ಅಥವಾ ನೋಟು ಹಾಕಿ. '
              'ನಿಖರ ಹಣ ಅಗತ್ಯವಿಲ್ಲ — ಚಿಲ್ಲರೆ ಮರಳಿ ಕೊಡಲಾಗುತ್ತದೆ.',
    ),
    (
      icon: Icons.qr_code,
      title: 'ಟೋಕನ್ ತೆಗೆದುಕೊಳ್ಳಿ',
      body:
          'ನಿಮ್ಮ ಟೋಕನ್ ಕೆಳಗಿನ ಸ್ಲಾಟ್‌ನಿಂದ ಬರುತ್ತದೆ. '
              'ಅದನ್ನು ತೆಗೆದು ಪ್ಲಾಟ್‌ಫಾರ್ಮ್ ಪ್ರವೇಶ ಗೇಟ್ ಮೇಲೆ ಟ್ಯಾಪ್ ಮಾಡಿ.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 3) {
      _anim.reset();
      setState(() => _step++);
      _anim.forward();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      _anim.reset();
      setState(() => _step--);
      _anim.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';
    final steps = isKannada ? _stepsKn : _stepsEn;
    final current = steps[_step];

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
          isKannada ? 'ಟೋಕನ್ ಯಂತ್ರ ಮಾರ್ಗದರ್ಶಿ' : 'Token Machine Guide',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const SizedBox(height: 100),
          // Step indicator dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final active = i == _step;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [if (active) BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 6)],
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Step photo placeholder
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, AppColors.surface.withValues(alpha: 0.8)],
                                ),
                              ),
                              child: Center(
                                child: Icon(current.icon, color: AppColors.primary.withValues(alpha: 0.2), size: 100),
                              ),
                            ),
                          ),
                          // Content
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      isKannada ? 'ಹಂತ ${_step + 1} / 4' : 'STEP ${_step + 1} OF 4',
                                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    current.title,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    current.body,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(fontSize: 18, color: Colors.white70, height: 1.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Nav buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_step > 0)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: _prevStep,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _step < 3 ? _nextStep : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(180, 64),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _step < 3
                              ? (isKannada ? 'ಮುಂದೆ' : 'Next Step')
                              : (isKannada ? 'ಮುಗಿಸಿ' : 'Finish'),
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
