import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_info.dart';
import '../utils/news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  @override
  void initState() {
    super.initState();
    NewsService.markAllSeen(); // the badge on the home screen disappears
  }

  Future<void> _refresh() async {
    await NewsService.check();
    await NewsService.markAllSeen();
    if (mounted) setState(() {});
  }

  Future<void> _openUpdate(NewsData data) async {
    final url = data.updateUrl.isNotEmpty ? data.updateUrl : AppInfo.apkUrl;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.colorScheme.onSurface;
    final subColor = textColor.withValues(alpha: 0.6);
    const goldAccent = Color(0xFFDFBA7B);

    final data = NewsService.current;
    final items = data?.items ?? [];
    final showUpdate = data != null && data.updateAvailable;

    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: (items.isEmpty && !showUpdate)
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: goldAccent.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'No news yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Pull down to check again.',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (showUpdate)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: goldAccent, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Update available',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Version ${data.latestVersion} is available. '
                            'You have version ${AppInfo.version}.',
                            style: TextStyle(fontSize: 15, color: textColor),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: () => _openUpdate(data),
                            icon: const Icon(Icons.download),
                            label: const Text('Update'),
                          ),
                        ],
                      ),
                    ),
                  for (final item in items)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: goldAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          if (item.date.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.date,
                              style: TextStyle(fontSize: 13, color: subColor),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            item.message,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
