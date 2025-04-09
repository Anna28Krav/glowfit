import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'registration_screen.dart';

class UserGoals {
  final int calories;
  final int waterGlasses;
  final int steps;

  UserGoals({required this.calories, required this.waterGlasses, required this.steps});
}

class HomeScreen extends StatefulWidget {
  final UserGoals userGoals;

  const HomeScreen({super.key, required this.userGoals});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int water = 0;
  int calories = 0;
  int steps = 0;
  String today = DateTime.now().toIso8601String().split('T').first;

  @override
  void initState() {
    super.initState();
    _checkDateAndLoad();
  }

  Future<void> _checkDateAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('lastDate');

    if (lastDate != today) {
      int prevWater = prefs.getInt('water') ?? 0;
      int prevCalories = prefs.getInt('calories') ?? 0;
      int prevSteps = prefs.getInt('steps') ?? 0;

      final historyJson = prefs.getString('history') ?? '{}';
      final historyData = jsonDecode(historyJson);
      historyData[lastDate ?? today] = {
        'water': prevWater,
        'calories': prevCalories,
        'steps': prevSteps
      };

      prefs.setString('history', jsonEncode(historyData));
      prefs.setString('lastDate', today);

      prefs.setInt('water', 0);
      prefs.setInt('calories', 0);
      prefs.setInt('steps', 0);
    }

    setState(() {
      water = prefs.getInt('water') ?? 0;
      calories = prefs.getInt('calories') ?? 0;
      steps = prefs.getInt('steps') ?? 0;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('water', water);
    prefs.setInt('calories', calories);
    prefs.setInt('steps', steps);
    prefs.setString('lastDate', today);
  }

  void _addManually(String type) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Введіть $type'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Наприклад: 100'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          )
        ],
      ),
    );

    if (result != null && int.tryParse(result) != null) {
      final value = int.parse(result);
      setState(() {
        if (type == 'воду') water += value;
        if (type == 'калорії') calories += value;
        if (type == 'кроки') steps += value;
      });
      _saveProgress();
    }
  }

  Map<String, int> _calculateKBJU(int kcal) {
    int proteins = ((kcal * 0.3) / 4).round(); // 30% білків
    int fats = ((kcal * 0.25) / 9).round();    // 25% жирів
    int carbs = ((kcal * 0.45) / 4).round();   // 45% вуглеводів
    return {'Б': proteins, 'Ж': fats, 'В': carbs};
  }

  @override
  Widget build(BuildContext context) {
    final kbju = _calculateKBJU(widget.userGoals.calories);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RegistrationScreen()),
            );
          },
        ),
        title: const Text('Трекер GlowFit'),
        backgroundColor: Colors.purple.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ласкаво просимо до GlowFit 💖',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TrackerCard(
              title: 'Вода 💧',
              current: water,
              goal: widget.userGoals.waterGlasses * 250,
              unit: 'мл',
              onAdd: () => _addManually('воду'),
            ),
            const SizedBox(height: 16),
            TrackerCard(
              title: 'Калорії 🔥',
              current: calories,
              goal: widget.userGoals.calories,
              unit: 'ккал',
              onAdd: () => _addManually('калорії'),
            ),
            const SizedBox(height: 8),
            Text(
              'Білки: ${kbju['Б']} г | Жири: ${kbju['Ж']} г | Вуглеводи: ${kbju['В']} г',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TrackerCard(
              title: 'Кроки 🚶‍♀️',
              current: steps,
              goal: widget.userGoals.steps,
              unit: 'кроків',
              onAdd: () => _addManually('кроки'),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackerCard extends StatelessWidget {
  final String title;
  final int current;
  final int goal;
  final String unit;
  final VoidCallback onAdd;

  const TrackerCard({
    super.key,
    required this.title,
    required this.current,
    required this.goal,
    required this.unit,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    double progress = goal > 0 ? current / goal : 0;
    if (progress > 1) progress = 1;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: Colors.purple,
              backgroundColor: Colors.purple.shade100,
            ),
            const SizedBox(height: 8),
            Text('$current / $goal $unit'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onAdd,
              child: const Text('+ Додати'),
            )
          ],
        ),
      ),
    );
  }
}
