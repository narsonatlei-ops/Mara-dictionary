import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mara_dictionary/providers/theme_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Google Sign In kawihna tur guider
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    // User lo lût tawh nge la lût lo tih lo ngaihven (listen) tu tur
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    // Silent sign in: An luh tawh hnu chuan an rawn luh nawn rualin auto-login a lo ti ang
    _googleSignIn.signInSilently();
  }

  // Google Sign In function tak tak
  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      debugPrint('Google Sign In Error: $error');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign in failed: $error')));
      }
    }
  }

  // Sign out function
  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  String _getFontSizeLabel(double size) {
    if (size <= 14.0) return 'Small';
    if (size <= 16.0) return 'Medium';
    return 'Large';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final primaryColor = isDarkMode
        ? const Color.fromARGB(255, 140, 15, 180)
        : themeProvider.primaryColor;

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white60 : Colors.black54;
    final dividerColor = isDarkMode ? Colors.white12 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. GOOGLE ACCOUNT SIGN IN SECTION (SIAMṬHAT THAR A NI TA)
          Container(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                // User thlalak neih chuan entir la, an neih loh emaw error a awm chuan offline Icon mawi deuh hman tur
                _currentUser != null && _currentUser!.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          _currentUser!.photoUrl!,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.account_circle,
                              size: 40,
                              color: subTextColor,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons
                            .account_circle, // Internet mamawh lo Material Icon kan hmang ta zawk e
                        size: 40,
                        color: isDarkMode
                            ? Colors.white30
                            : Colors.grey.shade400,
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser != null
                            ? _currentUser!.displayName ?? 'Google User'
                            : 'Google Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentUser != null
                            ? _currentUser!.email
                            : 'Sign in to backup and sync your data across devices',
                        style: TextStyle(fontSize: 13, color: subTextColor),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _currentUser != null
                      ? _handleSignOut
                      : _handleSignIn,
                  child: Text(
                    _currentUser != null ? 'Sign out' : 'Sign in',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 15, 40, 227),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),

          // 2. DARK THEME SWITCH
          Container(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                'Dark Theme',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                'Dark theme na hmâ khokhia enable/on tyh.',
                style: TextStyle(fontSize: 13, color: subTextColor),
              ),
              value: isDarkMode,
              activeThumbColor: primaryColor,
              onChanged: (bool value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),

          // 3. THEME PALETTE
          Container(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              title: Text(
                'Theme Palette',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                'Customize app colors and appearance.',
                style: TextStyle(fontSize: 13, color: subTextColor),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 15, height: 30, color: Colors.blue),
                  Container(width: 15, height: 30, color: Colors.purple),
                  Container(width: 15, height: 30, color: Colors.teal),
                ],
              ),
              onTap: () {
                _showThemePaletteDialog(context, themeProvider);
              },
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),

          // 4. PRONUNCIATION
          Container(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pronunciation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  'Android text-to-speech setting (Speech Rate).',
                  style: TextStyle(fontSize: 13, color: subTextColor),
                ),
                Slider(
                  value: themeProvider.speechRate,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  activeColor: primaryColor,
                  label:
                      '${themeProvider.speechRate.toStringAsFixed(1)}x Speed',
                  onChanged: (double val) {
                    themeProvider.setSpeechRate(val);
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),

          // 5. SET FONT SIZE
          Container(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                'Set Font Size',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                'Mohchho chhopasia na font size: ${_getFontSizeLabel(themeProvider.fontSize)}',
                style: TextStyle(fontSize: 13, color: subTextColor),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showFontSizeDialog(context, themeProvider);
              },
            ),
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
        ],
      ),
    );
  }

  void _showThemePaletteDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme Color'),
          content: const Text(
            'App chhôh liata hmâ na khohpa(Primary Color) â tlyh tyh:',
          ),
          actions: [
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    provider.setPrimaryColor(Colors.blue);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Blue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: () {
                    provider.setPrimaryColor(Colors.purple);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Purple',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    provider.setPrimaryColor(Colors.teal);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Teal',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Font Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Small', style: TextStyle(fontSize: 14)),
                onTap: () {
                  provider.setFontSize(14.0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Medium', style: TextStyle(fontSize: 16)),
                onTap: () {
                  provider.setFontSize(16.0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Large', style: TextStyle(fontSize: 20)),
                onTap: () {
                  provider.setFontSize(20.0);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
