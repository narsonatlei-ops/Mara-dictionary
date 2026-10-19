import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:mara_dictionary/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Google sign-in is used on the phone only (the web build needs extra setup)
  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;
  StreamSubscription<GoogleSignInAccount?>? _userSub;
  final FlutterTts _tts = FlutterTts();

  // Font size shown while the slider is moving (saved when the user lets go)
  late double _fontDraft;

  static const double _minFont = 12;
  static const double _maxFont = 24;

  @override
  void initState() {
    super.initState();
    _fontDraft = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).fontSize.clamp(_minFont, _maxFont).toDouble();

    if (!kIsWeb) {
      _googleSignIn = GoogleSignIn(scopes: ['email']);
      _userSub = _googleSignIn!.onCurrentUserChanged.listen((account) {
        if (mounted) setState(() => _currentUser = account);
      });
      _googleSignIn!.signInSilently();
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn?.signIn();
    } catch (error) {
      debugPrint('Google Sign In Error: $error');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign in failed: $error')));
      }
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn?.disconnect();
  }

  // Plays a sample so the user can hear the chosen speed
  Future<void> _testVoice(double rate) async {
    try {
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(rate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.speak('Hello, this is a sample pronunciation.');
    } catch (e) {
      debugPrint('Speech error: $e');
    }
  }

  String _rateLabel(double r) {
    if (r <= 0.25) return 'Slow';
    if (r <= 0.5) return 'Normal';
    if (r <= 0.75) return 'Fast';
    return 'Very fast';
  }

  void _changeFont(ThemeProvider p, double size) {
    final value = size.clamp(_minFont, _maxFont).toDouble();
    setState(() => _fontDraft = value);
    p.setFontSize(value);
  }

  Widget _section(Color bg, Color divider, Widget child) {
    return Column(
      children: [
        Container(color: bg, width: double.infinity, child: child),
        Divider(height: 1, thickness: 1, color: divider),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.colorScheme.onSurface;
    final subColor = textColor.withValues(alpha: 0.6);
    final divider = isDark ? Colors.white12 : Colors.grey.shade300;

    final titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: textColor,
    );
    final subStyle = TextStyle(fontSize: 13, color: subColor);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. GOOGLE ACCOUNT (phone only)
          if (!kIsWeb)
            _section(
              bg,
              divider,
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    _currentUser?.photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              _currentUser!.photoUrl!,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Icon(
                                Icons.account_circle,
                                size: 40,
                                color: subColor,
                              ),
                            ),
                          )
                        : Icon(Icons.account_circle, size: 40, color: subColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser != null
                                ? _currentUser!.displayName ?? 'Google User'
                                : 'Google Account',
                            style: titleStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentUser != null
                                ? _currentUser!.email
                                : 'Sign in with your Google account',
                            style: subStyle,
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
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 2. DARK THEME
          _section(
            bg,
            divider,
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text('Dark Theme', style: titleStyle),
              subtitle: Text(
                'Switch between light and dark mode.',
                style: subStyle,
              ),
              value: p.isDarkMode,
              onChanged: (_) => p.toggleTheme(),
            ),
          ),

          // 3. THEME PALETTE (any colour)
          _section(
            bg,
            divider,
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              title: Text('Theme Palette', style: titleStyle),
              subtitle: Text(
                'Choose any colour you like for the app.',
                style: subStyle,
              ),
              trailing: CircleAvatar(
                radius: 14,
                backgroundColor: p.primaryColor,
              ),
              onTap: () => _showColorPicker(p),
            ),
          ),

          // 4. PRONUNCIATION
          _section(
            bg,
            divider,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pronunciation speed', style: titleStyle),
                  Text('Speed: ${_rateLabel(p.speechRate)}', style: subStyle),
                  Slider(
                    value: p.speechRate.clamp(0.25, 1.0).toDouble(),
                    min: 0.25,
                    max: 1.0,
                    divisions: 3,
                    label: _rateLabel(p.speechRate),
                    onChanged: (v) => p.setSpeechRate(v),
                    onChangeEnd: (v) => _testVoice(v), // hear the new speed
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _testVoice(p.speechRate),
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Test voice'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. FONT SIZE (number)
          _section(
            bg,
            divider,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set Font Size', style: titleStyle),
                  Text('Size: ${_fontDraft.round()}', style: subStyle),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _fontDraft > _minFont
                            ? () => _changeFont(p, _fontDraft - 1)
                            : null,
                      ),
                      Expanded(
                        child: Slider(
                          value: _fontDraft,
                          min: _minFont,
                          max: _maxFont,
                          divisions: (_maxFont - _minFont).round(),
                          label: '${_fontDraft.round()}',
                          onChanged: (v) =>
                              setState(() => _fontDraft = v.roundToDouble()),
                          onChangeEnd: (v) => p.setFontSize(v.roundToDouble()),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _fontDraft < _maxFont
                            ? () => _changeFont(p, _fontDraft + 1)
                            : null,
                      ),
                    ],
                  ),
                  // Preview with the size that is being chosen
                  Text(
                    'Preview: accept (aksept) v. âpyh, zyh, âla',
                    textScaler: TextScaler.linear(_fontDraft / 16.0),
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- colour picker ----------------

  Widget _hsvSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 82, child: Text(label)),
        Expanded(
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showColorPicker(ThemeProvider p) {
    // Very light colours are not allowed, so the white titles stay readable
    HSVColor limit(HSVColor c) =>
        c.withValue(c.value.clamp(0.15, 0.85).toDouble());

    HSVColor hsv = limit(HSVColor.fromColor(p.primaryColor));

    final presets = <Color>[
      const Color(0xFF13263B), // Navy
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.brown,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          final color = hsv.toColor();
          final hex = color
              .toARGB32()
              .toRadixString(16)
              .padLeft(8, '0')
              .substring(2)
              .toUpperCase();

          return AlertDialog(
            title: const Text('Choose your colour'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$hex',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((c) {
                      return GestureDetector(
                        onTap: () =>
                            setLocal(() => hsv = limit(HSVColor.fromColor(c))),
                        child: CircleAvatar(radius: 16, backgroundColor: c),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  _hsvSlider(
                    'Colour',
                    hsv.hue,
                    0,
                    360,
                    (v) => setLocal(() => hsv = hsv.withHue(v)),
                  ),
                  _hsvSlider(
                    'Strength',
                    hsv.saturation,
                    0,
                    1,
                    (v) => setLocal(() => hsv = hsv.withSaturation(v)),
                  ),
                  _hsvSlider(
                    'Brightness',
                    hsv.value,
                    0.15,
                    0.85,
                    (v) => setLocal(() => hsv = hsv.withValue(v)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  p.setPrimaryColor(hsv.toColor());
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}
