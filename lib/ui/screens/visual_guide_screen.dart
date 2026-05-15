import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/route_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../data/models/metro_models.dart';
import 'token_machine_screen.dart';
import 'exit_finder_screen.dart';

/// Visual Guide Screen — UC-NMS-02: Step-by-step guidance.
/// Overhauled with premium high-fidelity UI.
class VisualGuideScreen extends StatefulWidget {
  const VisualGuideScreen({super.key});

  @override
  State<VisualGuideScreen> createState() => _VisualGuideScreenState();
}

class _VisualGuideScreenState extends State<VisualGuideScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _nextStep(int total) {
    if (_currentStep < total - 1) {
      setState(() {
        _currentStep++;
        _animCtrl.reset();
        _animCtrl.forward();
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _animCtrl.reset();
        _animCtrl.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeVM = context.watch<RouteViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';
    final route = routeVM.currentRoute;

    if (route.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Visual Guide')),
        body: Center(child: Text(isKannada ? 'ಮಾರ್ಗ ಇಲ್ಲ' : 'No route found', style: const TextStyle(color: AppColors.textSecondary))),
      );
    }

    final steps = _buildGuideSteps(route, isKannada);
    final totalSteps = steps.length;
    final step = steps[_currentStep];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isKannada ? 'ಮಾರ್ಗದರ್ಶನ' : 'Visual Guide',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                child: Text('${_currentStep + 1} / $totalSteps', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const SizedBox(height: 100),
          _buildProgressBar(totalSteps),
          Expanded(
            child: FadeTransition(
              opacity: _animCtrl,
              child: _buildStepCard(step, isKannada),
            ),
          ),
          _buildNavigation(totalSteps, isKannada),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white12,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [if (active) BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 4)],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepCard(_GuideStep step, bool isKannada) {
    return Padding(
      padding: const EdgeInsets.all(20),
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
                Expanded(
                  flex: 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildPlaceholderImage(step.title),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppColors.surface.withValues(alpha: 0.8)]),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.accent.withValues(alpha: 0.3))),
                              child: Text(step.type.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent)),
                            ),
                            const SizedBox(height: 10),
                            Text(step.title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isKannada ? 'ಹಂತ ಹಂತದ ಸೂಚನೆ' : 'Instructions', style: const TextStyle(color: AppColors.textDim, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(step.description, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white, height: 1.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(String title) {
    return Container(
      color: Colors.black26,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_outlined, color: Colors.white12, size: 64),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigation(int total, bool isKannada) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Row(
        children: [
          if (_currentStep > 0)
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surface, border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
              child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: _prevStep),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(180, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            onPressed: _currentStep < total - 1 ? () => _nextStep(total) : () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentStep < total - 1 ? (isKannada ? 'ಮುಂದೆ' : 'Next Step') : (isKannada ? 'ಮುಗಿಸಿ' : 'Finish'),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  List<_GuideStep> _buildGuideSteps(List<Station> route, bool isKannada) {
    final List<_GuideStep> s = [];
    final origin = route.first;

    // Step 1: Token Machine at Origin
    s.add(_GuideStep(
      type: 'Tickets',
      title: origin.name,
      description: isKannada ? 'ಟಿಕೆಟ್ ಕೌಂಟರ್ ಅಥವಾ ಮೆಷಿನ್‌ನಲ್ಲಿ ಟೋಕನ್ ಪಡೆಯಿರಿ.' : 'Go to the ticket counter or machine and get your token.',
    ));

    // Step 2: Platform at Origin
    s.add(_GuideStep(
      type: 'Platform',
      title: origin.name,
      description: isKannada ? '${origin.lineId.toUpperCase()} ಲೈನ್ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ಗೆ ಹೋಗಿ.' : 'Go to the ${origin.lineId.toUpperCase()} Line platform.',
    ));

    // Mid steps (Interchanges)
    for (int i = 0; i < route.length; i++) {
      final st = route[i];
      if (st.isInterchange && i > 0 && i < route.length - 1) {
        s.add(_GuideStep(
          type: 'Interchange',
          title: st.name,
          description: isKannada ? 'ಇಲ್ಲಿ ಕೆಳಗೆ ಇಳಿದು ಇನ್ನೊಂದು ಲೈನ್‌ಗೆ ಹೋಗಿ.' : 'Get off here and follow the signs to change lines.',
        ));
      }
    }

    // Final Step: Destination
    final dest = route.last;
    s.add(_GuideStep(
      type: 'Arrival',
      title: dest.name,
      description: isKannada ? 'ನಿಮ್ಮ ನಿಲ್ದಾಣ ಬಂದಿದೆ. ಎಕ್ಸಿಟ್ ಕಡೆಗೆ ನಡೆಯಿರಿ.' : 'You have arrived. Follow the signs to the Exit Gates.',
    ));

    return s;
  }
}

class _GuideStep {
  final String type;
  final String title;
  final String description;
  _GuideStep({required this.type, required this.title, required this.description});
}
