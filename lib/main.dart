import 'package:flutter/material.dart';

void main() => runApp(const DrugCalcApp());

class DrugCalcApp extends StatelessWidget {
  const DrugCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '薬剤投与計算',
      themeMode: ThemeMode.system, // システムのテーマに合わせる
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const DrugCalcPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DrugCalcPage extends StatefulWidget {
  const DrugCalcPage({super.key});

  @override
  State<DrugCalcPage> createState() => _DrugCalcPageState();
}

class _DrugCalcPageState extends State<DrugCalcPage> with TickerProviderStateMixin {
  final weightController = TextEditingController();
  final gammaController = TextEditingController();
  final drugController = TextEditingController();
  final volumeController = TextEditingController();
  final mlPerHourController = TextEditingController();

  // ハイライト用のフラグ
  Map<String, bool> highlightMap = {
    "weight": false,
    "gamma": false,
    "drug": false,
    "volume": false,
    "mlPerHour": false,
  };

  void highlightField(String key) {
    setState(() {
      highlightMap[key] = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        highlightMap[key] = false;
      });
    });
  }

  void calculate() {
    double? weight = double.tryParse(weightController.text);
    double? gamma = double.tryParse(gammaController.text);
    double? drug = double.tryParse(drugController.text);
    double? volume = double.tryParse(volumeController.text);
    double? mlPerHour = double.tryParse(mlPerHourController.text);

    int filled = [weight, gamma, drug, volume, mlPerHour].where((e) => e != null).length;

    if (filled < 4) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("計算できません"),
          content: const Text("5つのうち4つ以上の値を入力してください。"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      if (mlPerHour == null && weight != null && gamma != null && drug != null && volume != null) {
        mlPerHour = (gamma! * weight! * volume! * 60) / (drug! * 1000);
        mlPerHourController.text = mlPerHour!.toStringAsFixed(2);
        highlightField("mlPerHour");
      } else if (gamma == null && mlPerHour != null && weight != null && drug != null && volume != null) {
        gamma = (mlPerHour! * drug! * 1000) / (weight! * volume! * 60);
        gammaController.text = gamma!.toStringAsFixed(2);
        highlightField("gamma");
      } else if (weight == null && mlPerHour != null && gamma != null && drug != null && volume != null) {
        weight = (mlPerHour! * drug! * 1000) / (gamma! * volume! * 60);
        weightController.text = weight!.toStringAsFixed(2);
        highlightField("weight");
      } else if (drug == null && mlPerHour != null && gamma != null && weight != null && volume != null) {
        drug = (gamma! * weight! * volume! * 60) / (mlPerHour! * 1000);
        drugController.text = drug!.toStringAsFixed(2);
        highlightField("drug");
      } else if (volume == null && mlPerHour != null && gamma != null && weight != null && drug != null) {
        volume = (mlPerHour! * drug! * 1000) / (gamma! * weight! * 60);
        volumeController.text = volume!.toStringAsFixed(2);
        highlightField("volume");
      }
    });
  }

  Widget _buildInput(String label, TextEditingController controller, String key) {
    bool highlight = highlightMap[key] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: highlight,
          fillColor: highlight ? Colors.yellow.withAlpha(127) : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    gammaController.dispose();
    drugController.dispose();
    volumeController.dispose();
    mlPerHourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("薬剤投与計算ツール")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInput("体重 (kg)", weightController, "weight"),
              _buildInput("γ (μg/kg/min)", gammaController, "gamma"),
              _buildInput("薬剤量 (mg)", drugController, "drug"),
              _buildInput("溶媒量 (ml)", volumeController, "volume"),
              _buildInput("投与速度 (ml/h)", mlPerHourController, "mlPerHour"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: calculate,
                child: const Text("計算する"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
