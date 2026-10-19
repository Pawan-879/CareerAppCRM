import 'dart:convert';

import 'package:careerapp/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsListScreen extends StatefulWidget {
  final String staffId;

  const AppointmentsListScreen({super.key, required this.staffId});

  @override
  State<AppointmentsListScreen> createState() => _AppointmentsListScreenState();
}

class _AppointmentsListScreenState extends State<AppointmentsListScreen> {
  late Future<List<dynamic>> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = _loadAppointments();
  }

  Future<List<dynamic>> _loadAppointments() async {
    final query = Uri(queryParameters: {'staff_id': widget.staffId}).query;
    final response = await ApiService.getMethod3('/getStaffAppointments?$query');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Server returned ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true || body['data'] is! List) {
      throw Exception(
          body['message']?.toString() ?? 'Could not load appointments');
    }
    return body['data'] as List<dynamic>;
  }

  void _refresh() => setState(() => _appointments = _loadAppointments());

  String _date(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty || raw == '0000-00-00') return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Appointments'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
          ),
        ),
        actions: [
          IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh')
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _appointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off, size: 44, color: Colors.blueGrey),
                  const SizedBox(height: 12),
                  Text('${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: _refresh, child: const Text('Try Again')),
                ]),
              ),
            );
          }
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return const Center(child: Text('No appointments found'));
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              itemBuilder: (context, index) =>
                  _appointmentCard(rows[index] as Map<String, dynamic>),
            ),
          );
        },
      ),
    );
  }

  Widget _appointmentCard(Map<String, dynamic> appointment) {
    final status = appointment['status']?.toString() ?? 'pending';
    final name = appointment['student_name']?.toString() ?? 'Student';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetails(appointment),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                  backgroundColor: const Color(0xFFE0E7FF),
                  child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Color(0xFF4338CA),
                          fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('Appointment #${appointment['id'] ?? '—'}',
                        style: const TextStyle(color: Colors.blueGrey)),
                  ])),
              Chip(label: Text(status), visualDensity: VisualDensity.compact),
            ]),
            const SizedBox(height: 12),
            Text(
                '${appointment['class'] ?? 'Class not set'}  •  ${appointment['contact_no'] ?? 'No contact'}'),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.event, size: 16, color: Colors.blueGrey),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(
                      'Visit ${_date(appointment['visit_date'])}  •  ${appointment['time_slot'] ?? 'Time not set'}')),
              const Icon(Icons.chevron_right, color: Colors.blueGrey),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> a) {
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              title:
                  Text(a['student_name']?.toString() ?? 'Appointment Details'),
              content: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _detail('Appointment ID', a['id']),
                    _detail('Parent', a['father_name']),
                    _detail('Contact', a['contact_no']),
                    _detail('Second contact', a['contact_no2']),
                    _detail('Email', a['email']),
                    _detail('Class', a['class']),
                    _detail('Course / Branch', a['course']),
                    _detail('Interested in', a['interested']),
                    _detail('Type', a['appointment_type']),
                    _detail('Visit date', _date(a['visit_date'])),
                    _detail('Dropping date', _date(a['dropping_date'])),
                    _detail('Time slot', a['time_slot']),
                    _detail('Status', a['status']),
                  ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
  }

  Widget _detail(String label, dynamic value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
            '$label: ${value == null || value.toString().isEmpty ? '—' : value}'),
      );
}
