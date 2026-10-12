import 'package:flutter/material.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode
        ? const Color.fromARGB(255, 140, 15, 180)
        : const Color.fromARGB(255, 192, 21, 239);

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFFFFDF6),
      appBar: AppBar(
        title: const Text(
          'About Developer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. PROFILE PICTURE (Hrotlo.jpeg hman a ni ta e)
              CircleAvatar(
                radius: 55,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: primaryColor,
                  backgroundImage: const AssetImage('assets/Hrotlo.jpeg'),
                ),
              ),
              const SizedBox(height: 24),

              // Developer Name
              Text(
                'Z Hrotlo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              const Divider(thickness: 1),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chakhei, Siaha District, Mizoram',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: subTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'He Mara Dictionary App hi Nielit Aizawl Center lia Bca degree ei hnei tawhta zawpi hma thei awpa ta Ei build va chata, Mara reih a sia viata charô lyma thei nawpa chata a cha. UI nata database hmâtlah awhpa ta taopa a cha.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: subTextColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Footer Note
              Text(
                '© 2026 Narson. All Rights Reserved.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
