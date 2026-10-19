import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SeatAvailabilityScreen extends StatelessWidget {
  final List<Map<String, dynamic>> seatData;

  const SeatAvailabilityScreen({Key? key, required this.seatData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nextSaturday = DateTime.now().add(
      Duration(days: (6 - DateTime.now().weekday + 7) % 7),
    );
    final formattedDate = DateFormat('dd MMM, yyyy').format(nextSaturday);

    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text("Seats Availability"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Real-time seat availability (Last Date: $formattedDate)",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: seatData.length,
              itemBuilder: (context, index) {
                final data = seatData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: Colors.white10,
                  child: ListTile(
                    title: Text(
                      "${data['className']} (${data['category']})",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _seatChip("Ambala", data['Ambala']),
                        _seatChip("Yamunanagar", data['Yamunanagar']),
                        _seatChip("Patiala", data['Patiala']),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _seatChip(String center, String value) {
    Color color;
    if (value.toLowerCase() == 'full') {
      color = Colors.red;
    } else {
      int seats = int.tryParse(value) ?? 0;
      color = seats <= 3 ? Colors.orange : Colors.green;
    }

    return Chip(
      label: Text('$center: $value'),
      backgroundColor: color.withOpacity(0.8),
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}
