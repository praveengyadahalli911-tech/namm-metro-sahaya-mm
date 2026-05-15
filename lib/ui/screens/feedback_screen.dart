import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/feedback_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';

/// FeedbackScreen: Complete end-to-end user feedback UI.
/// Overhauled with premium dark theme and glassmorphism.
class FeedbackScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialStation;

  const FeedbackScreen({
    super.key,
    this.initialCategory,
    this.initialStation,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  final _messageCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();
  late AnimationController _successAnim;
  late Animation<double> _scaleAnim;

  static const _categories = [
    ('general', Icons.star_outline, 'General'),
    ('route', Icons.alt_route, 'Route Planning'),
    ('exit', Icons.door_front_door_outlined, 'Exit Finder'),
    ('token', Icons.confirmation_number_outlined, 'Token Machine'),
    ('visual', Icons.photo_camera_outlined, 'Visual Guide'),
  ];

  @override
  void initState() {
    super.initState();
    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _successAnim, curve: Curves.elasticOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<FeedbackViewModel>();
      vm.reset();
      if (widget.initialCategory != null) vm.setCategory(widget.initialCategory!);
      if (widget.initialStation != null) {
        vm.setStationName(widget.initialStation!);
        _stationCtrl.text = widget.initialStation!;
      }
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _stationCtrl.dispose();
    _successAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FeedbackViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isKannada ? 'ಪ್ರತಿಕ್ರಿಯೆ' : 'Feedback',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: vm.state == FeedbackState.success
            ? _buildSuccessCard(vm, isKannada)
            : _buildForm(vm, isKannada),
      ),
    );
  }

  Widget _buildSuccessCard(FeedbackViewModel vm, bool isKannada) {
    _successAnim.forward();
    return Center(
      key: const ValueKey('success'),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.check_circle_rounded, size: 50, color: AppColors.accent),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      vm.lastSubmitted?.ratingEmoji ?? '🤩',
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isKannada ? 'ಧನ್ಯವಾದ!' : 'Thank You!',
                      style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isKannada
                          ? 'ನಿಮ್ಮ ಪ್ರತಿಕ್ರಿಯೆ ನಮ್ಮ ಸೇವೆ ಸುಧಾರಿಸಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ.'
                          : 'Your feedback helps us improve Namma Metro Sahaya.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        _messageCtrl.clear();
                        _successAnim.reset();
                        vm.reset();
                      },
                      child: Text(isKannada ? 'ಇನ್ನೊಂದು ಸಲ ನೀಡಿ' : 'Give More Feedback',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(isKannada ? 'ಮುಖ್ಯ ಪುಟಕ್ಕೆ ಹಿಂತಿರುಗಿ' : 'Back to Home',
                          style: const TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(FeedbackViewModel vm, bool isKannada) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.fromLTRB(20, 110, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFormHeader(isKannada),
          const SizedBox(height: 32),
          _sectionLabel(isKannada ? 'ರೇಟಿಂಗ್ ನೀಡಿ *' : 'Rate Your Experience *'),
          const SizedBox(height: 16),
          _buildStarRating(vm),
          if (vm.rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  _ratingLabel(vm.rating, isKannada),
                  style: GoogleFonts.poppins(fontSize: 16, color: _ratingColor(vm.rating), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 32),
          _sectionLabel(isKannada ? 'ವಿಷಯ ಆಯ್ಕೆ ಮಾಡಿ' : 'Select Topic'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final selected = vm.category == cat.$1;
              return GestureDetector(
                onTap: () => vm.setCategory(cat.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: selected ? AppColors.primary : Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.$2, size: 16, color: selected ? Colors.white : AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(cat.$3, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          _sectionLabel(isKannada ? 'ನಿಮ್ಮ ಸಂದೇಶ *' : 'Your Message *'),
          const SizedBox(height: 12),
          _buildGlassField(
            controller: _messageCtrl,
            hint: isKannada ? 'ಇಲ್ಲಿ ಬರೆಯಿರಿ...' : 'Write your experience here...',
            maxLines: 4,
            onChanged: vm.setMessage,
          ),
          const SizedBox(height: 24),
          _sectionLabel(isKannada ? 'ನಿಲ್ದಾಣ (ಐಚ್ಛಿಕ)' : 'Station Name (Optional)'),
          const SizedBox(height: 12),
          _buildGlassField(
            controller: _stationCtrl,
            hint: isKannada ? 'ಉದಾ: ಮೆಜೆಸ್ಟಿಕ್' : 'e.g. Majestic',
            onChanged: vm.setStationName,
            prefix: Icons.place_outlined,
          ),
          const SizedBox(height: 24),
          _buildAnonymousToggle(vm, isKannada),
          const SizedBox(height: 32),
          if (vm.state == FeedbackState.error) _buildError(vm.errorMessage),
          ElevatedButton(
            onPressed: vm.state == FeedbackState.submitting ? null : vm.submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: vm.state == FeedbackState.submitting
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(isKannada ? 'ಪ್ರತಿಕ್ರಿಯೆ ಕಳುಹಿಸಿ' : 'Submit Feedback', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormHeader(bool isKannada) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accentBlue]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20)],
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isKannada ? 'ನಿಮ್ಮ ಅಭಿಪ್ರಾಯ ಹೇಳಿ' : 'Rate Your Ride', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(isKannada ? 'ನಿಮ್ಮ ಮಾತುಗಳು ನಮಗೆ ಮುಖ್ಯ!' : 'Your feedback drives us!', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassField({required TextEditingController controller, required String hint, int maxLines = 1, required Function(String) onChanged, IconData? prefix}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textDim),
          prefixIcon: prefix != null ? Icon(prefix, color: AppColors.primary) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildAnonymousToggle(FeedbackViewModel vm, bool isKannada) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_off_outlined, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(isKannada ? 'ಅನಾಮಿಕವಾಗಿ ಕಳುಹಿಸಿ' : 'Submit Anonymously', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
          ),
          Switch(
            value: vm.isAnonymous,
            onChanged: vm.setAnonymous,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(FeedbackViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final selected = starValue <= vm.rating;
        return GestureDetector(
          onTap: () => vm.setRating(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              selected ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 44,
              color: selected ? Colors.amber : Colors.white24,
            ),
          ),
        );
      }),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary));
  }

  Widget _buildError(String msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(msg, style: const TextStyle(color: AppColors.error, fontSize: 13)),
    );
  }

  String _ratingLabel(int r, bool isKannada) {
    if (isKannada) {
      switch (r) {
        case 1: return 'ತುಂಬಾ ಕೆಟ್ಟದ್ದು';
        case 2: return 'ಕೆಟ್ಟದ್ದು';
        case 3: return 'ಸರಿ';
        case 4: return 'ಒಳ್ಳೆಯದು';
        case 5: return 'ಅತ್ಯುತ್ತಮ!';
        default: return '';
      }
    } else {
      switch (r) {
        case 1: return 'Very Poor';
        case 2: return 'Poor';
        case 3: return 'Okay';
        case 4: return 'Good';
        case 5: return 'Excellent!';
        default: return '';
      }
    }
  }

  Color _ratingColor(int r) {
    switch (r) {
      case 1: return AppColors.error;
      case 2: return Colors.orange;
      case 3: return Colors.amber;
      case 4: return AppColors.accent;
      case 5: return AppColors.accent;
      default: return Colors.grey;
    }
  }
}
