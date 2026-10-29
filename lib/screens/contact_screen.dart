import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  final String _myEmail = 'atleihrotlo@gmail.com';
  final String _myWhatsAppNumber = '+919362624860';

  // true when both fields are filled
  bool _checkFields() {
    if (_subjectController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      _showSnackBar('Subject nata Message hi pabie khai tua tyh.');
      return false;
    }
    return true;
  }

  Future<void> _sendEmail() async {
    if (!_checkFields()) return;

    final emailUri = Uri(
      scheme: 'mailto',
      path: _myEmail,
      queryParameters: {
        'subject': _subjectController.text.trim(),
        'body': _messageController.text.trim(),
      },
    );

    try {
      final ok = await launchUrl(emailUri);
      if (!ok) _showSnackBar('Email app apahy thei vei!');
    } catch (e) {
      _showSnackBar('Email app apahy thei vei! $e');
    }
  }

  Future<void> _sendWhatsApp() async {
    if (!_checkFields()) return;

    final fullText =
        "Subject: ${_subjectController.text.trim()}\n\n"
        "Message: ${_messageController.text.trim()}";
    final cleanNumber = _myWhatsAppNumber.replaceAll('+', '');

    final whatsappUri = Uri.parse(
      "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(fullText)}",
    );

    try {
      final ok = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      if (!ok) _showSnackBar('WhatsApp apahy thei vei!');
    } catch (e) {
      _showSnackBar('WhatsApp apahy thei vei! $e');
    }
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final headerColor = Provider.of<ThemeProvider>(context).headerColor;
    final fieldColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    ButtonStyle buttonStyle() => ElevatedButton.styleFrom(
      backgroundColor: headerColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
    const buttonText = TextStyle(fontWeight: FontWeight.bold);

    // App bar and background colours come from the app theme (main.dart)
    return Scaffold(
      appBar: AppBar(title: const Text('Report Error/Contact')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A bie nata achhopasiana a do leipa tlyma na pahno khiata la, a ly ngâsâ pata ei vaw dao aw',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.87),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Subject',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: fieldColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendEmail,
                    icon: const Icon(Icons.send),
                    label: const Text('SEND EMAIL', style: buttonText),
                    style: buttonStyle(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendWhatsApp,
                    icon: const Icon(Icons.chat),
                    label: const Text('WHATSAPP', style: buttonText),
                    style: buttonStyle(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
