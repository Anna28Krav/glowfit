import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, dynamic> historyData = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('history') ?? '{}';
    setState(() {
      historyData = jsonDecode(historyJson);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = historyData.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // від нових до старих

    return Scaffold(
      appBar: AppBar(
        title: const Text('Історія прогресу'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: sortedDates.isEmpty
          ? const Center(child: Text('Ще немає збереженої історії.'))
          : ListView.builder(
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final date = sortedDates[index];
                final day = historyData[date];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text('📅 $date'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('💧 Вода: ${day['water']} скл.'),
                        Text('🔥 Калорії: ${day['calories']} ккал'),
                        Text('🚶‍♂️ Кроки: ${day['steps']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
