import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/route_viewmodel.dart';
import 'viewmodels/exit_viewmodel.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'viewmodels/nl_query_viewmodel.dart';
import 'viewmodels/feedback_viewmodel.dart';
import 'data/repositories/route_repository.dart';
import 'data/repositories/exit_repository.dart';
import 'data/repositories/feedback_repository.dart';
import 'ui/screens/route_query_screen.dart';
import 'ui/screens/bmrc_live_screen.dart';
import 'ui/screens/feedback_screen.dart';
import 'ui/screens/operator_dashboard_screen.dart';
import 'core/utils/security_utils.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/widgets/offline_badge.dart';
import 'ui/screens/exit_finder_screen.dart';
import 'ui/screens/token_machine_screen.dart';
import 'ui/screens/nl_query_screen.dart';
import 'ui/screens/emergency_info_screen.dart';
import 'core/services/translation_service.dart';
import 'core/services/station_data_service.dart';
import 'ui/screens/metro_map_screen.dart';
import 'dart:ui'; // Required for BackdropFilter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize repositories (single instances passed to ViewModels)
  final routeRepository = RouteRepository();
  final exitRepository = ExitRepository();
  final feedbackRepository = FeedbackRepository();

  // Initialize repositories (local seed data)
  await routeRepository.init();
  await exitRepository.init();

  // Initialize StationDataService — fetches REAL BMRCL station data
  // from Vonter/transitrouter (sourced from official BMRCL network map).
  // Falls back to bundled offline data if network unavailable.
  await StationDataService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => RouteViewModel(routeRepository)),
        ChangeNotifierProvider(
            create: (_) => ExitViewModel(exitRepository)),
        ChangeNotifierProvider(
            create: (_) => AdminViewModel(exitRepository)),
        ChangeNotifierProvider(create: (_) => NLQueryViewModel()),
        ChangeNotifierProvider(
            create: (_) => FeedbackViewModel(feedbackRepository)),
      ],
      child: const NammaMetroApp(),
    ),
  );
}

class NammaMetroApp extends StatelessWidget {
  const NammaMetroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();

    return MaterialApp(
      title: 'Namma Metro Sahaya',
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: const TextStyle(color: AppColors.textPrimary),
          bodyMedium: const TextStyle(color: AppColors.textSecondary),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface.withValues(alpha: 0.8),
          foregroundColor: AppColors.textPrimary,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            shadowColor: AppColors.primary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _trainCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _trainCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  @override
  void dispose() {
    _trainCtrl.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(children: [
          const Text('🚇', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              settings.translate('app_title'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const OfflineBadge(),
        ]),
        actions: [
          _CircleAction(icon: Icons.map_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MetroMapScreen()))),
          _CircleAction(icon: Icons.live_tv_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BmrcLiveScreen()))),
          _CircleAction(icon: Icons.feedback_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()))),
          _CircleAction(icon: Icons.settings,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          const SizedBox(width: 12),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(children: [

          // ── Animated train header ─────────────────────────────────────
          _AnimatedTrackHeader(trainCtrl: _trainCtrl, pulseCtrl: _pulseCtrl, isKannada: isKannada),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(children: [

              // ── BIG glowing CTA ──────────────────────────────────────
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3 + _pulseCtrl.value * 0.4),
                      blurRadius: 30 + _pulseCtrl.value * 15,
                      spreadRadius: 2,
                    )],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryDark.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RouteQueryScreen())),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 80),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('🚉', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 16),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                              Text(settings.translate('plan_journey'),
                                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              Text(isKannada ? 'ನಿಲ್ದಾಣ ಆಯ್ಕೆ ಮಾಡಿ →' : 'Pick source & destination →',
                                style: const TextStyle(fontSize: 12, color: Colors.white70)),
                            ]),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── HOW IT WORKS — 3 steps ───────────────────────────────
              _sectionTitle(isKannada ? '📖 ಹೇಗೆ ಉಪಯೋಗಿಸುವುದು?' : '📖 How to use?', isKannada),
              const SizedBox(height: 12),
              _StepCard(step: 1, icon: '📍', delay: 0,
                title: isKannada ? 'ಎಲ್ಲಿ ಹೋಗಬೇಕು ಹೇಳಿ' : 'Tell us where to go',
                subtitle: isKannada ? 'ಮೇಲಿನ ಬಟನ್ ಒತ್ತಿ, ನಿಲ್ದಾಣ ಆಯ್ಕೆ ಮಾಡಿ' : 'Tap the big button, pick your station'),
              const SizedBox(height: 8),
              _StepCard(step: 2, icon: '🗺️', delay: 100,
                title: isKannada ? 'ಮಾರ್ಗ ನೋಡಿ' : 'See your route',
                subtitle: isKannada ? 'ಯಾವ ರೈಲಿನಲ್ಲಿ ಹೋಗಬೇಕು ತೋರಿಸುತ್ತೇವೆ' : 'We show which train & how long'),
              const SizedBox(height: 8),
              _StepCard(step: 3, icon: '🎫', delay: 200,
                title: isKannada ? 'ಟಿಕೆಟ್ ಬೆಲೆ ತಿಳಿಯಿರಿ' : 'Know the fare',
                subtitle: isKannada ? 'ಟೋಕನ್ ಯಂತ್ರ ಉಪಯೋಗಿಸಲು ಮಾರ್ಗದರ್ಶನ' : 'Guided token machine instructions'),
              const SizedBox(height: 24),

              // ── Feature grid ─────────────────────────────────────────
              _sectionTitle(isKannada ? '🛠️ ಎಲ್ಲ ಸೇವೆಗಳು' : '🛠️ All Features', isKannada),
              const SizedBox(height: 12),
              _FeatureGrid(isKannada: isKannada),
              const SizedBox(height: 24),

              // ── Language picker ──────────────────────────────────────
              _sectionTitle(isKannada ? '🌐 ಭಾಷೆ ಆಯ್ಕೆ' : '🌐 Language', isKannada),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: TranslationService.supportedLocales.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final locale = TranslationService.supportedLocales[i];
                    final sel = settings.locale.languageCode == locale.languageCode;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: sel ? const LinearGradient(
                          colors: [Color(0xFF7B2FBE), Color(0xFF4A148C)]) : null,
                        border: Border.all(color: sel ? Colors.transparent : Colors.white24),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () => settings.setLanguage(locale.languageCode),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          child: Text(TranslationService.getLanguageName(locale.languageCode),
                            style: TextStyle(color: sel ? Colors.white : Colors.white60,
                              fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String text, bool isKannada) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text,
      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
  );
}

// ── Animated train track header ──────────────────────────────────────────────
class _AnimatedTrackHeader extends StatelessWidget {
  final AnimationController trainCtrl;
  final AnimationController pulseCtrl;
  final bool isKannada;
  const _AnimatedTrackHeader({required this.trainCtrl, required this.pulseCtrl, required this.isKannada});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0533), AppColors.background],
        ),
      ),
      child: Stack(children: [
        // Stars bg
        ...List.generate(18, (i) => Positioned(
          left: (i * 67.3) % 380,
          top: (i * 31.7) % 160,
          child: AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, __) => Opacity(
              opacity: 0.3 + (pulseCtrl.value * 0.5) * ((i % 3) * 0.3 + 0.1),
              child: const Text('✦', style: TextStyle(color: Colors.white, fontSize: 8)),
            ),
          ),
        )),

        // Purple track
        Positioned(left: 0, right: 0, top: 90,
          child: Container(height: 5,
            decoration: BoxDecoration(
              color: AppColors.primary,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.8), blurRadius: 15)]),
          ),
        ),
        // Green track
        Positioned(left: 0, right: 0, top: 108,
          child: Container(height: 5,
            decoration: BoxDecoration(
              color: AppColors.accent,
              boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.8), blurRadius: 15)]),
          ),
        ),

        // Moving train
        AnimatedBuilder(
          animation: trainCtrl,
          builder: (_, __) {
            final w = MediaQuery.of(context).size.width;
            final x = trainCtrl.value * (w + 60) - 60;
            return Positioned(left: x, top: 72,
              child: Column(children: [
                const Text('🚇', style: TextStyle(fontSize: 32)),
                Container(width: 40, height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(colors: [
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.3),
                    ]),
                  ),
                ),
              ]),
            );
          },
        ),

        // Title text
        Positioned(left: 0, right: 0, bottom: 20,
          child: Column(children: [
            Text('ನಮ್ಮ ಮೆಟ್ರೋ ಸಹಾಯ', textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKannada(color: Colors.white,
                fontSize: 22, fontWeight: FontWeight.bold,
                shadows: [const Shadow(color: Color(0xFFAB47BC), blurRadius: 12)])),
            Text(isKannada ? 'ಮೊದಲ ಬಾರಿಯವರಿಗೆ ಮಾರ್ಗದರ್ಶಿ' : 'First-timer\'s Metro Guide',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }
}

// ── Step card ────────────────────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  final int step;
  final String icon;
  final String title;
  final String subtitle;
  final int delay;
  const _StepCard({required this.step, required this.icon, required this.title,
    required this.subtitle, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Opacity(opacity: v.clamp(0, 1),
        child: Transform.translate(offset: Offset(40 * (1 - v), 0), child: child)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(children: [
              Container(width: 44, height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark]),
                ),
                child: Center(child: Text('$step', style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
              ),
              const SizedBox(width: 14),
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.poppins(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Feature grid ─────────────────────────────────────────────────────────────
class _FeatureGrid extends StatelessWidget {
  final bool isKannada;
  const _FeatureGrid({required this.isKannada});

  @override
  Widget build(BuildContext context) {
    final items = [
      _FeatItem('🚉', isKannada ? 'ರೈಲು ಮಾರ್ಗ' : 'Plan Route',
        AppColors.primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RouteQueryScreen()))),
      _FeatItem('🗺️', isKannada ? 'ಮೆಟ್ರೋ ನಕ್ಷೆ' : 'Metro Map',
        AppColors.accentBlue, () => Navigator.push(context, PageRouteBuilder(
          pageBuilder: (_, a, __) => const MetroMapScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400)))),
      _FeatItem('🚪', isKannada ? 'ಗೇಟ್ ಹುಡುಕಿ' : 'Exit Finder',
        const Color(0xFF00695C), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExitFinderScreen()))),
      _FeatItem('🎫', isKannada ? 'ಟೋಕನ್ ಯಂತ್ರ' : 'Token Machine',
        AppColors.warning, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TokenMachineScreen()))),
      _FeatItem('🤖', isKannada ? 'AI ಸಹಾಯ' : 'AI Help',
        AppColors.success, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NLQueryScreen()))),
      _FeatItem('🚑', isKannada ? 'ತುರ್ತು' : 'Emergency',
        AppColors.error, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyInfoScreen()))),
      _FeatItem('👷', isKannada ? 'ಆಪರೇಟರ್' : 'Operator',
        AppColors.textSecondary, () => showAdminPinGate(context, const OperatorDashboardScreen())),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.95),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final it = items[i];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + i * 80),
          curve: Curves.easeOutBack,
          builder: (_, v, child) => Transform.scale(scale: v.clamp(0, 1), child: child),
          child: GestureDetector(
            onTap: it.onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: it.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: it.color.withValues(alpha: 0.3)),
                    boxShadow: [BoxShadow(color: it.color.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(it.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 6),
                    Text(it.label, textAlign: TextAlign.center,
                      style: TextStyle(color: it.color, fontSize: 11,
                        fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface.withValues(alpha: 0.5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

class _FeatItem {
  final String icon, label;
  final Color color;
  final VoidCallback onTap;
  const _FeatItem(this.icon, this.label, this.color, this.onTap);
}
