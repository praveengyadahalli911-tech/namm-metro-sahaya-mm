import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/bmrc_info_service.dart';
import '../../core/services/station_data_service.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'metro_map_screen.dart';

class BmrcLiveScreen extends StatefulWidget {
  const BmrcLiveScreen({super.key});
  @override
  State<BmrcLiveScreen> createState() => _BmrcLiveScreenState();
}

class _BmrcLiveScreenState extends State<BmrcLiveScreen>
    with SingleTickerProviderStateMixin {
  late Timer _ticker;
  late TabController _tabs;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _tabs.dispose();
    super.dispose();
  }

  BmrcTimeOfDay get _tod => BmrcTimeOfDay(hour: _now.hour, minute: _now.minute);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    final isKn = settings.locale.languageCode == 'kn';
    final running = BmrcInfoService.isMetroRunning(at: _tod);
    final freq = BmrcInfoService.getFrequency(_tod);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isKn ? 'ನಮ್ಮ ಮೆಟ್ರೋ ಮಾಹಿತಿ' : 'BMRC Live Info',
          style: GoogleFonts.notoSansKannada(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.notoSansKannada(fontWeight: FontWeight.bold),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: isKn ? 'ಲೈವ್' : 'Live'),
            Tab(text: isKn ? 'ದರ ಪಟ್ಟಿ' : 'Fares'),
            Tab(text: isKn ? 'ನಿಯಮಗಳು' : 'Rules'),
            Tab(text: isKn ? 'ನಿಲ್ದಾಣಗಳು' : 'Stations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildLiveTab(isKn, running, freq),
          _buildFaresTab(isKn),
          _buildRulesTab(isKn),
          _buildStationsTab(isKn),
        ],
      ),
    );
  }

  // ── Tab 1: Live Status ─────────────────────────────────────────────────────
  Widget _buildLiveTab(bool isKn, bool running, ServiceFrequency freq) {
    final purpleNext = BmrcInfoService.minutesToNextTrain('purple', at: _tod);
    final greenNext  = BmrcInfoService.minutesToNextTrain('green',  at: _tod);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Status banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: running
                  ? [Colors.green.shade700, Colors.green.shade400]
                  : [Colors.red.shade700, Colors.red.shade400],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Icon(
              running ? Icons.train_rounded : Icons.do_not_disturb_on_rounded,
              color: Colors.white, size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              running
                  ? (isKn ? 'ಮೆಟ್ರೋ ಓಡುತ್ತಿದೆ ✅' : 'Metro is Running ✅')
                  : (isKn ? 'ಮೆಟ್ರೋ ಮುಚ್ಚಿದೆ 🔴' : 'Metro Not Operating 🔴'),
              style: GoogleFonts.notoSansKannada(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isKn
                  ? 'ಈಗಿನ ಸಮಯ: ${_now.hour.toString().padLeft(2,'0')}:${_now.minute.toString().padLeft(2,'0')}'
                  : 'Current time: ${_now.hour.toString().padLeft(2,'0')}:${_now.minute.toString().padLeft(2,'0')}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Operating hours card
        _infoCard(
          isKn ? 'ಕಾರ್ಯಾಚರಣೆ ಸಮಯ' : 'Operating Hours',
          Icons.schedule_rounded,
          AppColors.primary,
          [
            _hoursRow('🟣 ${isKn ? "ನೇರಳೆ ಮಾರ್ಗ" : "Purple Line"}', '05:30 AM – 11:30 PM'),
            _hoursRow('🟢 ${isKn ? "ಹಸಿರು ಮಾರ್ಗ" : "Green Line"}',  '05:30 AM – 11:30 PM'),
          ],
        ),
        const SizedBox(height: 12),

        // Next train estimate
        if (running) ...[
          _infoCard(
            isKn ? 'ಮುಂದಿನ ರೈಲು (ಅಂದಾಜು)' : 'Next Train (Estimate)',
            Icons.directions_transit_rounded,
            AppColors.accent,
            [
              _hoursRow('🟣 ${isKn ? "ನೇರಳೆ" : "Purple"}',
                  purpleNext > 0 ? '~$purpleNext ${isKn ? "ನಿಮಿಷ" : "min"}' : '--'),
              _hoursRow('🟢 ${isKn ? "ಹಸಿರು" : "Green"}',
                  greenNext > 0 ? '~$greenNext ${isKn ? "ನಿಮಿಷ" : "min"}' : '--'),
              const SizedBox(height: 4),
              Text(
                isKn
                    ? '📊 ${freq.labelKn} — ನೇರಳೆ: ${freq.purpleFreqMins} ನಿಮಿಷ | ಹಸಿರು: ${freq.greenFreqMins} ನಿಮಿಷ'
                    : '📊 ${freq.label} — Purple: every ${freq.purpleFreqMins} min | Green: every ${freq.greenFreqMins} min',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Contact card
        _infoCard(
          isKn ? 'ಸಂಪರ್ಕ (BMRC ಅಧಿಕೃತ)' : 'Contact (BMRC Official)',
          Icons.phone_in_talk_rounded,
          Colors.teal,
          [
            _hoursRow('📞 ${isKn ? "ಸಹಾಯವಾಣಿ" : "Helpline"}', BmrcInfoService.helplineNumber),
            _hoursRow('✉️ Email', BmrcInfoService.travelHelpEmail),
            _hoursRow('💬 WhatsApp', BmrcInfoService.whatsappNumber),
          ],
        ),
        const SizedBox(height: 12),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber),
          ),
          child: Text(
            isKn
                ? '⚠️ ಮೇಲಿನ ರೈಲು ಸಮಯಗಳು BMRC ಅಧಿಕೃತ ವೇಳಾಪಟ್ಟಿ ಆಧಾರಿತ. ನೈಜ-ಸಮಯ ತಡಕಗಳಿಗೆ ನಮ್ಮ ಮೆಟ್ರೋ ಅಪ್ ಬಳಸಿ.'
                : '⚠️ Train times above are based on BMRC\'s official schedule. For real-time delays use the Namma Metro official app.',
            style: GoogleFonts.notoSansKannada(fontSize: 12, color: Colors.amber[800]),
          ),
        ),
      ]),
    );
  }

  // ── Tab 2: Official Fare Table ─────────────────────────────────────────────
  Widget _buildFaresTab(bool isKn) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: [
            const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              isKn ? 'ಅಧಿಕೃತ ದರ ಪಟ್ಟಿ (bmrc.co.in)' : 'Official Fare Table (bmrc.co.in)',
              style: GoogleFonts.notoSansKannada(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              isKn ? 'ಫೆಬ್ರವರಿ 2025 ಪರಿಷ್ಕೃತ' : 'Revised Feb 2025',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // Fare table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(children: [
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(children: [
                Expanded(child: Text(isKn ? 'ದೂರ' : 'Distance',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                SizedBox(width: 80, child: Text(isKn ? 'ಟೋಕನ್' : 'Token',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                SizedBox(width: 90, child: Text(isKn ? 'ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್' : 'Smart Card',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              ]),
            ),
            ...BmrcInfoService.officialFareSlabs.asMap().entries.map((e) {
              final slab = e.value;
              final isEven = e.key % 2 == 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isEven ? Colors.grey.shade50 : Colors.white,
                child: Row(children: [
                  Expanded(child: Text(slab.slabLabel,
                      style: GoogleFonts.robotoMono(fontSize: 13))),
                  SizedBox(width: 80, child: Text('₹${slab.tokenFare}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600))),
                  SizedBox(width: 90, child: Text('₹${slab.smartCardFare}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.green[700]))),
                ]),
              );
            }),
            // Footer note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Text(
                isKn
                    ? '💳 ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್‌ನಲ್ಲಿ 5% ರಿಯಾಯಿತಿ. ಗರಿಷ್ಠ ₹3000 ಲೋಡ್ ಮಾಡಬಹುದು.'
                    : '💳 5% discount with Smart Card. Max load: ₹3000 at station.',
                style: TextStyle(fontSize: 12, color: Colors.green[800]),
                textAlign: TextAlign.center,
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Tab 3: Official Rules ──────────────────────────────────────────────────
  Widget _buildRulesTab(bool isKn) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: BmrcInfoService.officialRules.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i == 0) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              isKn
                  ? 'ಅಧಿಕೃತ ನಿಯಮಗಳು — bmrc.co.in/fare-rules'
                  : 'Official Rules — bmrc.co.in/fare-rules',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKannada(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        }
        final rule = BmrcInfoService.officialRules[i - 1];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rule.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                isKn ? rule.titleKn : rule.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                isKn ? rule.detailKn : rule.detail,
                style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
              ),
            ])),
          ]),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _infoCard(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        ]),
        const Divider(height: 16),
        ...children,
      ]),
    );
  }

  Widget _hoursRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }

  // ── Tab 4: Real BMRCL Stations ─────────────────────────────────────────────
  Widget _buildStationsTab(bool isKn) {
    final svc = StationDataService();
    final stations = svc.stations;
    final isLive = svc.isLive;

    // Group by line
    final purple = stations.where((s) => s.lineColor == '#e542de').toList();
    final green  = stations.where((s) => s.lineColor == '#009933').toList();
    final yellow = stations.where((s) => s.lineColor == '#FFD700').toList();
    final inter  = stations.where((s) => s.lineColor == 'interchange').toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Source badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isLive ? Colors.green.shade700 : Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(
                    isLive ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                    color: Colors.white, size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isLive
                          ? (isKn
                              ? '✅ ಲೈವ್ ಡೇಟಾ — Vonter/transitrouter (BMRCL ಅಧಿಕೃತ ನೆಟ್‌ವರ್ಕ್ ನಕ್ಷೆ)'
                              : '✅ Live data — Vonter/transitrouter (BMRCL official network map)')
                          : (isKn
                              ? '📦 ಆಫ್‌ಲೈನ್ ಡೇಟಾ — BMRCL Phase-1 + Phase-2A'
                              : '📦 Offline data — BMRCL Phase-1 + Phase-2A'),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),

              // Summary cards
              Row(children: [
                _lineCountCard('🟣', isKn ? 'ನೇರಳೆ' : 'Purple', purple.length, const Color(0xFFe542de)),
                const SizedBox(width: 8),
                _lineCountCard('🟢', isKn ? 'ಹಸಿರು' : 'Green', green.length, const Color(0xFF009933)),
                const SizedBox(width: 8),
                _lineCountCard('🟡', isKn ? 'ಹಳದಿ' : 'Yellow', yellow.length, const Color(0xFFFFD700)),
              ]),
              const SizedBox(height: 8),
              Text(
                isKn
                    ? 'ಒಟ್ಟು ${stations.length} ನಿಲ್ದಾಣಗಳು (${inter.length} ಇಂಟರ್‌ಚೇಂಜ್ ಸೇರಿ)'
                    : 'Total ${stations.length} stations (incl. ${inter.length} interchange)',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ]),
          ),
        ),
        // Purple Line
        _sliverLineHeader('🟣 ${isKn ? "ನೇರಳೆ ಮಾರ್ಗ" : "Purple Line"}', const Color(0xFFe542de)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _stationTile(purple[i], const Color(0xFFe542de)),
            childCount: purple.length,
          ),
        ),

        // Green Line
        _sliverLineHeader('🟢 ${isKn ? "ಹಸಿರು ಮಾರ್ಗ" : "Green Line"}', const Color(0xFF009933)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _stationTile(green[i], const Color(0xFF009933)),
            childCount: green.length,
          ),
        ),

        // Yellow Line
        if (yellow.isNotEmpty) ...[
          _sliverLineHeader('🟡 ${isKn ? "ಹಳದಿ ಮಾರ್ಗ (ಹಂತ-೨)" : "Yellow Line (Phase-2)"}', const Color(0xFFFFD700)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _stationTile(yellow[i], const Color(0xFFFFD700)),
              childCount: yellow.length,
            ),
          ),
        ],

        // Interchange
        if (inter.isNotEmpty) ...[
          _sliverLineHeader('🔴 ${isKn ? "ಇಂಟರ್‌ಚೇಂಜ್ ನಿಲ್ದಾಣಗಳು" : "Interchange Stations"}', Colors.red),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _stationTile(inter[i], Colors.red),
              childCount: inter.length,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _lineCountCard(String emoji, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text('$count', style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
        ]),
      ),
    );
  }

  SliverToBoxAdapter _sliverLineHeader(String title, Color color) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
      ),
    );
  }

  Widget _stationTile(MetroStation station, Color lineColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
      ),
      child: Row(children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lineColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(station.name, style: const TextStyle(fontSize: 13))),
        if (station.isInterchange)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Interchange',
                style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
          ),
      ]),
    );
  }
}
