import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a WhatsApp chat with the given number via the wa.me deep link.
/// Falls back silently (shows a snackbar) if no app can handle the URL,
/// e.g. WhatsApp not installed and no browser fallback available.
class WhatsappContactButton extends StatelessWidget {
  const WhatsappContactButton({super.key, required this.phoneNumber});

  /// Nigerian local format is fine (e.g. "09066772894") — converted to
  /// international format internally.
  final String phoneNumber;

  String get _internationalNumber {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('234')) return digits;
    if (digits.startsWith('0')) return '234${digits.substring(1)}';
    return digits;
  }

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/$_internationalNumber');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _open(context),
      tooltip: 'Chat with us on WhatsApp',
      icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366)),
    );
  }
}
