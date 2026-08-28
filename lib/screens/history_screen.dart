import 'package:flutter/material.dart';
import '../utils/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Database atanga history lak chhuahna
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getHistory();
    setState(() {
      _historyList = data;
      _isLoading = false;
    });
  }

  // History zawng zawng thiahna
  Future<void> _clearAllHistory() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('History pathai'),
        content: const Text('Na history zydua na pathai kho hmeisei ma?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearHistory();
              Navigator.pop(context);
              _loadHistory(); // A tharin rawn thian fai rawh
            },
            child: const Text('Ok', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
          192,
          21,
          239,
        ), // I AppBar rawng mawi kha
        title: const Text(
          'Search History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_historyList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
              onPressed: _clearAllHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyList.isEmpty
          ? const Center(
              child: Text(
                'Mohchho na charô pa khâhmâh y mâh vei.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _historyList.length,
              itemBuilder: (context, index) {
                // <--- Heta 'index' tih kan dah fiah hian a tawk chiah e
                final item =
                    _historyList[index]; // <--- Hemi tlar hian va thlak tawp rawh

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  elevation: 1,
                  child: ListTile(
                    leading: const Icon(Icons.history, color: Colors.grey),
                    title: Text(
                      item['word'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      item['meaning'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Heta i hmeh hian kha a hma a 'Word Details' phekah khan zuang lut leh thin tur a ni e
                    },
                  ),
                );
              },
            ),
    );
  }
}
