import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/route_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../data/models/metro_models.dart';
import 'route_result_screen.dart';
import 'nl_query_screen.dart';
import 'emergency_info_screen.dart';
import 'feedback_screen.dart';

/// Route Query Screen — UC-NMS-01: free-text autocomplete for source +
/// destination, validation error banners, swap button, GenAI section.
class RouteQueryScreen extends StatefulWidget {
  const RouteQueryScreen({super.key});

  @override
  State<RouteQueryScreen> createState() => _RouteQueryScreenState();
}

class _RouteQueryScreenState extends State<RouteQueryScreen> {
  // Controllers hold the display text so we can reset them on swap
  final TextEditingController _srcCtrl = TextEditingController();
  final TextEditingController _dstCtrl = TextEditingController();

  final FocusNode _srcFocus = FocusNode();
  final FocusNode _dstFocus = FocusNode();

  // Track whether user has touched each field (for error display)
  bool _srcTouched = false;
  bool _dstTouched = false;

  @override
  void dispose() {
    _srcCtrl.dispose();
    _dstCtrl.dispose();
    _srcFocus.dispose();
    _dstFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeVM = context.watch<RouteViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(children: [
          const Text('🚉', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(settings.translate('plan_journey'),
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
        ]),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Visual guide banner ───────────────────────────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (_, v, child) => Opacity(opacity: v,
                  child: Transform.translate(offset: Offset(0, 20*(1-v)), child: child)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.accentBlue.withValues(alpha: 0.1)]),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Text('👇', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(
                          isKannada
                            ? 'ಎಲ್ಲಿಂದ ಎಲ್ಲಿಗೆ ಹೋಗಬೇಕು? ಕೆಳಗೆ ಆಯ್ಕೆ ಮಾಡಿ!'
                            : 'Where are you going? Pick your stations below!',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                      ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Route input card ──────────────────────────────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (_, v, child) => Transform.scale(scale: 0.9 + 0.1*v,
                  child: Opacity(opacity: v.clamp(0,1), child: child)),
                child: _buildRouteInputCard(context, routeVM, settings, isKannada),
              ),
              const SizedBox(height: 12),

              // ── Error banner ──────────────────────────────────────────
              if (routeVM.errorMessage.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: _buildErrorBanner(routeVM.errorMessage),
                ),
              const SizedBox(height: 16),

              // ── Find Route button ─────────────────────────────────────
              _buildFindRouteButton(context, routeVM, settings, isKannada),
              const SizedBox(height: 32),

              // ── GenAI section ─────────────────────────────────────────
              _buildGenAISection(context, isKannada),
              const SizedBox(height: 24),

              // ── Quick Actions ─────────────────────────────────────────
              _QuickActionsRow(isKannada: isKannada),
            ],
          ),
        ),
      ),
    );
  }

  // ── Route Input Card ──────────────────────────────────────────────────
  Widget _buildRouteInputCard(
      BuildContext context, RouteViewModel routeVM, SettingsViewModel settings, bool isKannada) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildAutocompleteField(
                context: context,
                controller: _srcCtrl,
                focusNode: _srcFocus,
                label: settings.translate('source'),
                hint: settings.translate('source'),
                icon: Icons.radio_button_checked,
                iconColor: AppColors.primary,
                selected: routeVM.source,
                onSelected: (station) {
                  routeVM.setSource(station);
                  setState(() => _srcTouched = true);
                  FocusScope.of(context).requestFocus(_dstFocus);
                },
                allStations: routeVM.allStations,
                searchFn: routeVM.searchStations,
                showError: _srcTouched && routeVM.source == null,
                errorText: isKannada ? 'ಮೂಲ ನಿಲ್ದಾಣ ಆಯ್ಕೆ ಮಾಡಿ' : 'Please select a source station',
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleButton(
                    icon: Icons.swap_vert_rounded,
                    onPressed: () {
                      routeVM.swapStations();
                      _srcCtrl.text = routeVM.source?.name ?? '';
                      _dstCtrl.text = routeVM.destination?.name ?? '';
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildAutocompleteField(
                context: context,
                controller: _dstCtrl,
                focusNode: _dstFocus,
                label: settings.translate('destination'),
                hint: settings.translate('destination'),
                icon: Icons.location_on,
                iconColor: const Color(0xFF43A047),
                selected: routeVM.destination,
                onSelected: (station) {
                  routeVM.setDestination(station);
                  setState(() => _dstTouched = true);
                },
                allStations: routeVM.allStations,
                searchFn: routeVM.searchStations,
                showError: _dstTouched && routeVM.destination == null,
                errorText: isKannada ? 'ಗಮ್ಯಸ್ಥಾನ ನಿಲ್ದಾಣ ಆಯ್ಕೆ ಮಾಡಿ' : 'Please select a destination station',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Autocomplete Field ─────────────────────────────────────────────────
  Widget _buildAutocompleteField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required Station? selected,
    required Function(Station) onSelected,
    required List<Station> allStations,
    required List<Station> Function(String) searchFn,
    required bool showError,
    required String errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSansKannada(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return RawAutocomplete<Station>(
              textEditingController: controller,
              focusNode: focusNode,
              displayStringForOption: (s) => s.name,
              optionsBuilder: (TextEditingValue val) {
                if (val.text.isEmpty) return allStations;
                return searchFn(val.text);
              },
              onSelected: (Station station) {
                controller.text = station.name;
                onSelected(station);
                FocusScope.of(context).unfocus();
              },
              fieldViewBuilder:
                  (context, fieldCtrl, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: fieldCtrl,
                  focusNode: focusNode,
                  onTap: () {
                    // Force show options when tapped
                    if (fieldCtrl.text.isEmpty) {
                      fieldCtrl.value = fieldCtrl.value.copyWith(text: '');
                    }
                  },
                  style: GoogleFonts.notoSansKannada(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(icon, color: iconColor, size: 22),
                    suffixIcon: selected != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _LineBadge(lineId: selected.lineId),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: showError
                            ? AppColors.warning
                            : Colors.grey.shade200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: iconColor, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    shadowColor: Colors.black26,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 240,
                        maxWidth: constraints.maxWidth,
                      ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final station = options.elementAt(index);
                      return InkWell(
                        borderRadius: index == 0
                            ? const BorderRadius.vertical(
                                top: Radius.circular(12))
                            : index == options.length - 1
                                ? const BorderRadius.vertical(
                                    bottom: Radius.circular(12))
                                : BorderRadius.zero,
                        onTap: () => onSelected(station),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              _LineDot(lineId: station.lineId),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  station.name,
                                  style: GoogleFonts.notoSansKannada(
                                      fontSize: 15),
                                ),
                              ),
                              if (station.isInterchange)
                                const Icon(Icons.swap_horiz,
                                    size: 16,
                                    color: Colors.amber),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
    if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(
                  color: AppColors.warning, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ── Find Route Button ──────────────────────────────────────────────────
  Widget _buildFindRouteButton(
      BuildContext context, RouteViewModel routeVM, SettingsViewModel settings, bool isKannada) {
    final canSearch =
        routeVM.source != null && routeVM.destination != null;

    if (routeVM.isCalculating) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: canSearch
          ? () async {
              setState(() {
                _srcTouched = true;
                _dstTouched = true;
              });
              FocusScope.of(context).unfocus();
              final nav = Navigator.of(context); // capture before await
              final success = await routeVM.findRoute();
              if (mounted && success) {
                nav.push(
                  MaterialPageRoute(
                      builder: (_) => const RouteResultScreen()),
                );
              }
            }
          : () {
              // Show validation hints even on tap
              setState(() {
                _srcTouched = true;
                _dstTouched = true;
              });
            },
      icon: const Icon(Icons.search_rounded),
      label: Text(
        settings.translate('get_route'),
        style: GoogleFonts.notoSansKannada(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            canSearch ? AppColors.primary : Colors.grey.shade300,
        foregroundColor: canSearch ? Colors.white : Colors.grey.shade600,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: canSearch ? 4 : 0,
      ),
    );
  }

  // ── Error Banner ───────────────────────────────────────────────────────
  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.warning.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.notoSansKannada(
                  color: AppColors.warning, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── GenAI Section ──────────────────────────────────────────────────────
  Widget _buildGenAISection(BuildContext context, bool isKannada) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightPurpleBg,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primary.withAlpha(40)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isKannada
                      ? 'ನೈಸರ್ಗಿಕ ಭಾಷೆಯಲ್ಲಿ ಕೇಳಿ (GenAI)'
                      : 'Ask in Natural Language (GenAI)',
                  style: GoogleFonts.notoSansKannada(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('BETA',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _GenAITextField(isKannada: isKannada),
        ],
      ),
    );
  }
}

// ── Small helper widgets ───────────────────────────────────────────────────

/// Input field in the GenAI section — opens NLQueryScreen on send
class _GenAITextField extends StatefulWidget {
  final bool isKannada;
  const _GenAITextField({required this.isKannada});

  @override
  State<_GenAITextField> createState() => _GenAITextFieldState();
}

class _GenAITextFieldState extends State<_GenAITextField> {
  final TextEditingController _ctrl = TextEditingController();

  void _openChat() {
    final query = _ctrl.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => NLQueryScreen(initialQuery: query)),
    );
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      style: GoogleFonts.notoSansKannada(fontSize: 15),
      onSubmitted: (_) => _openChat(),
      decoration: InputDecoration(
        hintText: widget.isKannada
            ? '"ಮೆಜೆಸ್ಟಿಕ್‌ನಿಂದ ಜಯನಗರಕ್ಕೆ ಹೋಗುವುದು ಹೇಗೆ?"'
            : '"How do I reach Jayanagar from Majestic?"',
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send_rounded, color: AppColors.primary),
          onPressed: _openChat,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}


class _LineDot extends StatelessWidget {
  final String lineId;
  const _LineDot({required this.lineId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: lineId == 'purple' ? AppColors.primary : AppColors.accent,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Chip badge showing which line a selected station is on
class _LineBadge extends StatelessWidget {
  final String lineId;
  const _LineBadge({required this.lineId});

  @override
  Widget build(BuildContext context) {
    final isPurple = lineId == 'purple';
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color:
              (isPurple ? AppColors.primary : AppColors.accent).withAlpha(20),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          isPurple ? 'Purple' : 'Green',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isPurple ? AppColors.primary : AppColors.accent,
          ),
        ),
      ),
    );
  }
}

/// Quick Actions Row at the bottom of the Home Screen
class _QuickActionsRow extends StatelessWidget {
  final bool isKannada;
  const _QuickActionsRow({required this.isKannada});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          icon: Icons.emergency,
          label: isKannada ? 'ತುರ್ತು' : 'Emergency',
          color: AppColors.warning,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmergencyInfoScreen()),
          ),
        ),
        _buildActionButton(
          context,
          icon: Icons.feedback_outlined,
          label: isKannada ? 'ಪ್ರತಿಕ್ರಿಯೆ' : 'Feedback',
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedbackScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.notoSansKannada(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary, size: 24),
        onPressed: onPressed,
      ),
    );
  }
}
