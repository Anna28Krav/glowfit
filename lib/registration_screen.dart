import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _calorieController = TextEditingController();
  final _waterController = TextEditingController();
  final _stepsController = TextEditingController();
  String _goal = 'Схуднення';
  String _lossType = '0.5 кг/тиждень';
  String _gender = 'Чоловік';
  String _activity = 'Помірний';
  bool _customValues = false;
  bool _safeLoss = false;

  @override
  void initState() {
    super.initState();
    _checkIfReturningFromHome();
  }

  Future<void> _checkIfReturningFromHome() async {
    final prefs = await SharedPreferences.getInstance();
    final fromHome = prefs.getBool('fromHome') ?? false;
    if (fromHome) {
      await _loadSavedData();
    } else {
      await prefs.clear();
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('name') ?? '';
    _ageController.text = prefs.getString('age') ?? '';
    _heightController.text = prefs.getString('height') ?? '';
    _weightController.text = prefs.getString('weight') ?? '';
    _calorieController.text = prefs.getString('calories') ?? '';
    _waterController.text = prefs.getString('water') ?? '';
    _stepsController.text = prefs.getString('steps') ?? '';
    setState(() {
      _goal = prefs.getString('goal') ?? 'Схуднення';
      _lossType = prefs.getString('lossType') ?? '0.5 кг/тиждень';
      _gender = prefs.getString('gender') ?? 'Чоловік';
      _activity = prefs.getString('activity') ?? 'Помірний';
      _customValues = prefs.getBool('customValues') ?? false;
      _safeLoss = prefs.getBool('safeLoss') ?? false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('age', _ageController.text);
    await prefs.setString('height', _heightController.text);
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('calories', _calorieController.text);
    await prefs.setString('water', _waterController.text);
    await prefs.setString('steps', _stepsController.text);
    await prefs.setString('goal', _goal);
    await prefs.setString('lossType', _lossType);
    await prefs.setString('gender', _gender);
    await prefs.setString('activity', _activity);
    await prefs.setBool('customValues', _customValues);
    await prefs.setBool('safeLoss', _safeLoss);
    await prefs.setBool('fromHome', true);
  }

  int _calculateCalories(String height, String weight, String goal, String lossType, bool safeLoss, String gender, String ageStr) {
    final h = int.tryParse(height) ?? 160;
    final w = int.tryParse(weight) ?? 60;
    final age = int.tryParse(ageStr) ?? 20;
    double bmr;
    if (gender == 'Жінка') {
      bmr = 10 * w + 6.25 * h - 5 * age - 161;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * age + 5;
    }
    double calories = bmr * 1.4;

    if (goal == 'Схуднення') {
      if (safeLoss) {
        calories -= 250;
      } else {
        switch (lossType) {
          case '0.5 кг/тиждень':
            calories -= 500;
            break;
          case '1 кг/тиждень':
            calories -= 1000;
            break;
          case '2 кг/тиждень':
            calories -= 1500;
            break;
        }
      }
    } else if (goal == 'Набір ваги') {
      calories += 300;
    }

    return calories.clamp(1000, 4000).toInt();
  }

  int _calculateSteps(String goal, String activity, int age) {
    int baseSteps;
    switch (activity) {
      case 'Малоактивний':
        baseSteps = 8000;
        break;
      case 'Помірний':
        baseSteps = 10000;
        break;
      case 'Активний':
        baseSteps = 12000;
        break;
      default:
        baseSteps = 10000;
    }

    if (goal == 'Схуднення') baseSteps += 2000;
    if (goal == 'Набір ваги') baseSteps -= 1000;
    if (age > 50) baseSteps -= 1000;
    if (age < 25) baseSteps += 500;

    return baseSteps.clamp(3000, 20000);
  }

  int _calculateWater(String weight) {
    final w = int.tryParse(weight) ?? 60;
    final ml = (w * 30).round();
    return (ml / 250).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Реєстрація'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ваше ім’я'),
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Вік'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Стать:'),
              DropdownButton<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Чоловік', child: Text('Чоловік')),
                  DropdownMenuItem(value: 'Жінка', child: Text('Жінка')),
                ],
                onChanged: (value) {
                  setState(() => _gender = value!);
                },
              ),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Зріст (см)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Вага (кг)'),
                keyboardType: TextInputType.number,
              ),
              const Text('Активність:'),
              DropdownButton<String>(
                value: _activity,
                items: const [
                  DropdownMenuItem(value: 'Малоактивний', child: Text('Малоактивний')),
                  DropdownMenuItem(value: 'Помірний', child: Text('Помірний')),
                  DropdownMenuItem(value: 'Активний', child: Text('Активний')),
                ],
                onChanged: (value) {
                  setState(() => _activity = value!);
                },
              ),
              const SizedBox(height: 16),
              const Text('Ціль:'),
              DropdownButton<String>(
                value: _goal,
                items: const [
                  DropdownMenuItem(value: 'Схуднення', child: Text('Схуднення')),
                  DropdownMenuItem(value: 'Підтримка', child: Text('Підтримка ваги')),
                  DropdownMenuItem(value: 'Набір ваги', child: Text('Набір ваги')),
                ],
                onChanged: (value) {
                  setState(() => _goal = value!);
                },
              ),
              if (_goal == 'Схуднення')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: const Text('Просто схуднення (безпечне)'),
                      value: _safeLoss,
                      onChanged: (val) {
                        setState(() => _safeLoss = val!);
                      },
                    ),
                    if (!_safeLoss)
                      DropdownButton<String>(
                        value: _lossType,
                        items: const [
                          DropdownMenuItem(value: '0.5 кг/тиждень', child: Text('0.5 кг/тиждень')),
                          DropdownMenuItem(value: '1 кг/тиждень', child: Text('1 кг/тиждень')),
                          DropdownMenuItem(value: '2 кг/тиждень', child: Text('2 кг/тиждень')),
                        ],
                        onChanged: (value) {
                          setState(() => _lossType = value!);
                        },
                      ),
                  ],
                ),
              const Divider(height: 32),
              SwitchListTile(
                title: const Text('Ввести власні значення'),
                value: _customValues,
                onChanged: (val) {
                  setState(() => _customValues = val);
                },
              ),
              if (_customValues) ...[
                TextFormField(
                  controller: _calorieController,
                  decoration: const InputDecoration(labelText: 'Калорій на день'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _waterController,
                  decoration: const InputDecoration(labelText: 'Склянок води'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _stepsController,
                  decoration: const InputDecoration(labelText: 'Кроків на день'),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _saveData();
                    final age = int.tryParse(_ageController.text) ?? 20;

                    final calories = _customValues
                        ? int.tryParse(_calorieController.text) ?? 2000
                        : _calculateCalories(
                            _heightController.text,
                            _weightController.text,
                            _goal,
                            _lossType,
                            _safeLoss,
                            _gender,
                            _ageController.text,
                          );

                    final water = _customValues
                        ? int.tryParse(_waterController.text) ?? 8
                        : _calculateWater(_weightController.text);

                    final steps = _customValues
                        ? int.tryParse(_stepsController.text) ?? 10000
                        : _calculateSteps(_goal, _activity, age);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          userGoals: UserGoals(
                            calories: calories,
                            waterGlasses: water,
                            steps: steps,
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Почати'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
