import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  // !!! HETA HI I EMAIL LEH WHATSAPP NUMBER DIK TAK KHA VA DAH RAWH U !!!
  final String _myEmail = 'atleihrotlo@gmail.com';
  final String _myWhatsAppNumber =
      '+919362624860'; // Country code (+91) telh ngei ngei tur aw

  // 1. EMAIL THAWNNA (URL_LAUNCHER NEW VERSION DIK TAK)
  Future<void> _sendEmail() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      _showSnackBar('Subject nata Message hi pabie khai tua tyh.');
      return;
    }

    // Email Uri felfai takin
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _myEmail,
      queryParameters: {'subject': subject, 'body': message},
    );

    try {
      // url_launcher thar bera an hman dan a ni e:
      await launchUrl(emailUri);
    } catch (e) {
      _showSnackBar('Email app apahy thei vei! $e');
    }
  }

  // 2. WHATSAPP VIAU LUHNA (URL_LAUNCHER NEW VERSION DIK TAK)
  Future<void> _sendWhatsApp() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      _showSnackBar('Subject nata Message hi pabie khai tua tyh.');
      return;
    }

    final fullText = "Subject: $subject\n\nMessage: $message";
    final cleanNumber = _myWhatsAppNumber.replaceAll('+', '');

    // External application a hawn tlat angai hrim hrim a nia whatsapp hi chu
    final Uri whatsappUri = Uri.parse(
      "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(fullText)}",
    );

    try {
      await launchUrl(
        whatsappUri,
        mode: LaunchMode
            .externalApplication, // Phone-a WhatsApp app tak tak a hawn nan
      );
    } catch (e) {
      _showSnackBar('WhatsApp apahy thei vei! $e');
    }
  }

  void _showSnackBar(String text) {
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
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFFDF6,
      ), // I app background rawng ngai bawk kha
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          12,
          38,
          236,
        ), // I AppBar rawng mawi tak kha
        title: const Text(
          'Report Error/Contact',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A bie nata achhopasiana a do leipa tlyma na pahno khiata la, a ly ngâsâ pata ei vaw dao aw',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // SUBJECT INPUT
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // MESSAGE INPUT (A hmun a len deuh nan maxLines kan pe ang)
            TextField(
              controller: _messageController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // BUTTONS ROW (I thlalak rawn thawn ang chiah khan)
            Row(
              children: [
                // EMAIL BUTTON
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendEmail,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text(
                      'SEND EMAIL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF1E88E5,
                      ), // Blue rawng mawi tak kha
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // WHATSAPP BUTTON
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendWhatsApp,
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text(
                      'WHATSAPP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
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
