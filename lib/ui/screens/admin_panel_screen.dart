import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/route_viewmodel.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../data/models/exit_gate_model.dart';
import '../../data/models/metro_models.dart';

/// UC-NMS-07: Admin Panel — Manage Station Exit Data
/// FR-NMS-14: Add/edit exit gates. Only visible to admin users.
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  Station? _selectedStation;

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();
    final routeVM = context.watch<RouteViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final isKannada = settings.locale.languageCode == 'kn';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isKannada ? 'ಆಡಳಿತ ಫಲಕ' : 'Admin Panel',
          style: GoogleFonts.notoSansKannada(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: const Text('ADMIN',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: AppColors.warning,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedStation != null
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () => _showExitForm(context, adminVM, null, isKannada),
              icon: const Icon(Icons.add),
              label: Text(isKannada ? 'ನಿರ್ಗಮನ ಸೇರಿಸಿ' : 'Add Exit'),
            )
          : null,
      body: Column(
        children: [
          // Station picker
          Container(
            color: AppColors.lightPurpleBg,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isKannada ? 'ನಿಲ್ದಾಣ ಆಯ್ಕೆ ಮಾಡಿ:' : 'Select Station:',
                  style: GoogleFonts.notoSansKannada(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Station>(
                      isExpanded: true,
                      value: _selectedStation,
                      hint: Text(
                          isKannada ? 'ನಿಲ್ದಾಣ ಆಯ್ಕೆ ಮಾಡಿ' : 'Pick a station'),
                      items: routeVM.allStations
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name),
                              ))
                          .toList(),
                      onChanged: (station) {
                        setState(() => _selectedStation = station);
                        if (station != null) {
                          adminVM.selectStation(station.id);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Exit list
          Expanded(
            child: _selectedStation == null
                ? Center(
                    child: Text(
                    isKannada
                        ? 'ನಿರ್ಗಮನ ನೋಡಲು ನಿಲ್ದಾಣ ಆಯ್ಕೆ ಮಾಡಿ'
                        : 'Select a station to view exits',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ))
                : adminVM.stationExits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.door_front_door,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              isKannada
                                  ? 'ಈ ನಿಲ್ದಾಣಕ್ಕೆ ನಿರ್ಗಮನ ದ್ವಾರ ಇಲ್ಲ'
                                  : 'No exits added for this station yet.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: adminVM.stationExits.length,
                        itemBuilder: (context, i) {
                          final gate = adminVM.stationExits[i];
                          return _buildExitTile(
                              context, adminVM, gate, isKannada);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildExitTile(BuildContext context, AdminViewModel adminVM,
      ExitGate gate, bool isKannada) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Text(
            gate.gateNumber.replaceAll(RegExp(r'[^0-9]'), ''),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(gate.gateNumber,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gate.directionLabel),
            Text(
              '~${gate.walkingDistM}m · ${gate.landmarks.join(", ")}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primary),
              onPressed: () =>
                  _showExitForm(context, adminVM, gate, isKannada),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.warning),
              onPressed: () => _confirmDelete(context, adminVM, gate, isKannada),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExitForm(BuildContext context, AdminViewModel adminVM,
      ExitGate? existing, bool isKannada) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExitFormSheet(
        station: _selectedStation!,
        existing: existing,
        adminVM: adminVM,
        isKannada: isKannada,
      ),
    );
    adminVM.refreshExits();
  }

  Future<void> _confirmDelete(BuildContext context, AdminViewModel adminVM,
      ExitGate gate, bool isKannada) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isKannada ? 'ಅಳಿಸಿ?' : 'Delete?'),
        content: Text(isKannada
            ? '${gate.gateNumber} ಅಳಿಸಲಾಗುತ್ತದೆ.'
            : 'Delete ${gate.gateNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isKannada ? 'ರದ್ದು' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: Text(isKannada ? 'ಅಳಿಸಿ' : 'Delete',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) adminVM.deleteExit(gate.exitId);
  }
}

/// FR-NMS-14: Exit gate add/edit form
class _ExitFormSheet extends StatefulWidget {
  final Station station;
  final ExitGate? existing;
  final AdminViewModel adminVM;
  final bool isKannada;

  const _ExitFormSheet({
    required this.station,
    this.existing,
    required this.adminVM,
    required this.isKannada,
  });

  @override
  State<_ExitFormSheet> createState() => _ExitFormSheetState();
}

class _ExitFormSheetState extends State<_ExitFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gateCtrl;
  late TextEditingController _dirCtrl;
  late TextEditingController _distCtrl;
  late TextEditingController _landmarksCtrl;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _gateCtrl = TextEditingController(text: e?.gateNumber ?? '');
    _dirCtrl = TextEditingController(text: e?.directionLabel ?? '');
    _distCtrl =
        TextEditingController(text: e != null ? '${e.walkingDistM}' : '');
    _landmarksCtrl = TextEditingController(
        text: e != null ? e.landmarks.join(', ') : '');
  }

  @override
  void dispose() {
    _gateCtrl.dispose();
    _dirCtrl.dispose();
    _distCtrl.dispose();
    _landmarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final gate = ExitGate(
      exitId: widget.existing?.exitId ??
          'EX_${DateTime.now().millisecondsSinceEpoch}',
      stationId: widget.station.id,
      gateNumber: _gateCtrl.text.trim(),
      directionLabel: _dirCtrl.text.trim(),
      walkingDistM: int.parse(_distCtrl.text.trim()),
      landmarks: _landmarksCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );

    final success = await widget.adminVM.saveExit(gate);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              widget.isKannada ? 'ಯಶಸ್ವಿಯಾಗಿ ಉಳಿಸಲಾಗಿದೆ' : 'Saved successfully'),
          backgroundColor: AppColors.accent,
        ),
      );
    } else {
      setState(() => _inlineError = widget.adminVM.saveError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKannada = widget.isKannada;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existing == null
                        ? (isKannada ? 'ನಿರ್ಗಮನ ಸೇರಿಸಿ' : 'Add Exit Gate')
                        : (isKannada ? 'ನಿರ್ಗಮನ ಸಂಪಾದಿಸಿ' : 'Edit Exit Gate'),
                    style: GoogleFonts.notoSansKannada(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_inlineError != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_inlineError!,
                    style: const TextStyle(color: AppColors.warning)),
              ),
            _buildField(
              controller: _gateCtrl,
              label: isKannada ? 'ಗೇಟ್ ಸಂಖ್ಯೆ *' : 'Gate Number *',
              hint: 'e.g. Gate 1',
              maxLength: 10, // CVE-3 fix
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _dirCtrl,
              label:
                  isKannada ? 'ದಿಕ್ಕು ಲೇಬಲ್ * (≤30 ಅಕ್ಷರ)' : 'Direction Label * (≤30 chars)',
              hint: 'e.g. North Exit',
              maxLength: 30, // CVE-3 fix
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length > 30) return 'Max 30 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _distCtrl,
              label: isKannada ? 'ನಡಿಗೆ ದೂರ (ಮೀ.) *' : 'Walking Distance (m) *',
              hint: 'e.g. 150',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = int.tryParse(v);
                if (n == null || n <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _landmarksCtrl,
              label: isKannada
                  ? 'ಗುರುತಿನ ಸ್ಥಳಗಳು (ಅಲ್ಪವಿರಾಮ ಬೇರ್ಪಡಿಸಿ)'
                  : 'Landmarks (comma separated)',
              hint: 'e.g. KSRTC Bus Stand, Gandhi Nagar',
              maxLength: 200, // CVE-3 fix
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isKannada ? 'ಉಳಿಸಿ' : 'Save',
                style: GoogleFonts.notoSansKannada(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int? maxLength, // CVE-3: input length enforcement
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      style: GoogleFonts.notoSansKannada(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.warning),
        ),
      ),
    );
  }
}
