import 'package:flutter/material.dart';

class UniqueFeaturesPage extends StatelessWidget {
    static const routeName = '/uniquefeatures';

  static const List<String> features = [
    // "30-35 students teaching per class",
    "Fully AC and eco-friendly campus/hostel",
    "Smart interactive classes",
    "NDA NCC training",
    "SSB interview training",
    "Personality development classes",
    "Maths lab",
    "Indoor sports auditorium",
    "Gym training",
    "300+ CCTV cameras with security room",
    "Daily report in CDS app",
    "Hockey, football, cricket ground",
    "Swimming training",
    "Horse riding",
    "Students beyond from the national boundaries",
    "Training session with Dr. Rajesh Saini",
    "Weekly inter-school sports matches",
    "Weekly leadership management training",
    "Daily hobby classes",
  ];

  const UniqueFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unique Features"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: features.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.blueAccent),
                title: Text(
                  features[index],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UniqueFeaturesPage(),
  ));
}
