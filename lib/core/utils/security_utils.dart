import 'package:flutter/material.dart';

/// ── CVE-2 FIX: PIN-gated admin access ────────────────────────────────────────
/// Shows a 4-digit PIN dialog before allowing access to admin screens.
/// In production: replace hardcoded PIN with a bcrypt-hashed value from
/// a secure backend or flutter_secure_storage.
Future<void> showAdminPinGate(BuildContext context, Widget adminScreen) async {
  final pinCtrl = TextEditingController();
  const correctPin = '1234'; // 🔐 Change this before production release

  final granted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [
        Text('🔐', style: TextStyle(fontSize: 24)),
        SizedBox(width: 8),
        Text('Admin Access', style: TextStyle(color: Colors.white)),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Enter your 4-digit PIN to continue.',
            style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 16),
        TextField(
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          autofocus: true,
          style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 20),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: const Color(0xFF0D1117),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7B2FBE))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7B2FBE), width: 2)),
            hintText: '●●●●',
            hintStyle: const TextStyle(color: Colors.white24),
          ),
        ),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B2FBE)),
          onPressed: () => Navigator.pop(context, pinCtrl.text == correctPin),
          child: const Text('Enter', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (granted == true && context.mounted) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => adminScreen));
  } else if (granted == false && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Incorrect PIN. Access denied.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
