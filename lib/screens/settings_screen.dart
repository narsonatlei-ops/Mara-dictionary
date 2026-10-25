import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mara_dictionary/providers/theme_provider.dart';
import '../utils/app_info.dart';
import '../utils/speech_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Font size shown while the slider is moving
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
  }

  @override
  void dispose() {
    SpeechService.instance.stop();
    super.dispose();
  }

  // Plays a sample so the user can hear the chosen speed
  void _testVoice(double rate) {
    SpeechService.instance.speak(
      'Hello, this is a sample pronunciation.',
      rate,
    );
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

  Future<void> _openLink(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the link.')));
    }
  }

  Future<void> _confirmReset(ThemeProvider p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to default'),
        content: const Text(
          'All settings will return to their default values. '
          'Your favorites and history are not removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    p.resetToDefaults();
    setState(() => _fontDraft = 16);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings were reset.')));
  }

  // A heading for a group of settings
  Widget _header(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // A white (or dark) block with a divider under it
  Widget _block(Color bg, Color divider, Widget child) {
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
    final headerColor = isDark ? const Color(0xFFDFBA7B) : p.primaryColor;

    final titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: textColor,
    );
    final subStyle = TextStyle(fontSize: 13, color: subColor);

    Widget switchTile(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
    ) {
      return _block(
        bg,
        divider,
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          title: Text(title, style: titleStyle),
          subtitle: Text(subtitle, style: subStyle),
          value: value,
          onChanged: onChanged,
        ),
      );
    }

    Widget linkTile(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
    ) {
      return _block(
        bg,
        divider,
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Icon(icon, color: subColor),
          title: Text(title, style: titleStyle),
          subtitle: subtitle.isEmpty ? null : Text(subtitle, style: subStyle),
          onTap: onTap,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ---------------- Appearance ----------------
          _header('Appearance', headerColor),
          switchTile(
            'Dark Theme',
            'Switch between light and dark mode.',
            p.isDarkMode,
            (_) => p.toggleTheme(),
          ),
          _block(
            bg,
            divider,
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
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
          _block(
            bg,
            divider,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                ],
              ),
            ),
          ),

          // ---------------- Pronunciation ----------------
          _header('Pronunciation', headerColor),
          _block(
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
          switchTile(
            'Speak the word automatically',
            'The English word is pronounced when you open it on the home screen.',
            p.autoSpeak,
            p.setAutoSpeak,
          ),

          // ---------------- Search ----------------
          _header('Search', headerColor),
          switchTile(
            'Search inside words',
            'Off: words that start with your text. On: words that contain it.',
            p.searchContains,
            p.setSearchContains,
          ),

          // ---------------- Data ----------------
          _header('Data', headerColor),
          switchTile(
            'Get synonyms and antonyms online',
            'Off: no internet is used; only the ones already saved are shown.',
            p.fetchOnline,
            p.setFetchOnline,
          ),
          linkTile(
            Icons.restore,
            'Reset to default',
            'Settings only. Favorites and history are kept.',
            () => _confirmReset(p),
          ),

          // ---------------- About ----------------
          _header('About', headerColor),
          linkTile(Icons.info_outline, 'Version', AppInfo.version, () {}),
          linkTile(
            Icons.security,
            'Privacy Policy',
            '',
            () => _openLink(AppInfo.privacyUrl),
          ),
          linkTile(
            Icons.share,
            'Share the app',
            '',
            () => Share.share(
              '${AppInfo.name}\n\nWeb version: ${AppInfo.webUrl}\n\nDirect apk download: ${AppInfo.apkUrl}',
            ),
          ),
          linkTile(
            Icons.description_outlined,
            'Open-source licenses',
            '',
            () => showLicensePage(
              context: context,
              applicationName: AppInfo.name,
              applicationVersion: AppInfo.version,
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
      const Color(0xFF13263B),
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
