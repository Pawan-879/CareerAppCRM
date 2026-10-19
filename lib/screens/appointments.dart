import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Appointments extends StatefulWidget {
  static const String routeName = '/appointments';
  // Supply session cookie / authorized headers from your existing login.
  final Map<String, String> authHeaders;
  const Appointments({Key? key, this.authHeaders = const {}}) : super(key: key);
  @override
  State<Appointments> createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  final TextEditingController _search = TextEditingController();
  final List<Map<String, dynamic>> _items = [];
  bool _loading = false;
  String? _error;
  String _branch = 'All';
  String _status = 'All';
  String _period = 'All records';
  bool _todayFollowups = false;
  int _page = 1, _totalPages = 1, _total = 0;

  static const Map<String, String> statuses = {
    'All': '',
    'Not Visited': '0',
    'Visited': '1',
    'Registered': '2',
    'Admission': '3',
    'Old Parent Visit': '4',
    'Refund': '5',
    'Registration But Drop': '6'
  };
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Map<String, String> _params() {
    final q = <String, String>{'page': '$_page'};
    if (_search.text.trim().isNotEmpty) q['search'] = _search.text.trim();
    if (_branch != 'All') q['branch'] = _branch;
    if (_status != 'All') q['visit_status'] = statuses[_status]!;
    if (_todayFollowups) q['followup_today'] = '1';
    final now = DateTime.now();
    DateTime? start, end;
    switch (_period) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        end = start;
        break;
      case 'Yesterday':
        start = DateTime(now.year, now.month, now.day - 1);
        end = start;
        break;
      case 'This week':
        start = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        end = now;
        break;
      case 'Last week':
        end = DateTime(now.year, now.month, now.day - now.weekday);
        start = end.subtract(const Duration(days: 6));
        break;
      case 'This month':
        start = DateTime(now.year, now.month, 1);
        end = now;
        break;
      case 'Last month':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        break;
    }
    if (start != null) q['start_date'] = DateFormat('yyyy-MM-dd').format(start);
    if (end != null) q['end_date'] = DateFormat('yyyy-MM-dd').format(end);
    return q;
  }

  String? _sessionToken;
  Future<void> _loadLoginToken() async {
    final prefs=await SharedPreferences.getInstance();
    String? token=prefs.getString('api_token') ?? prefs.getString('auth_token');
    for (final key in ['staffData','userData','consulData']) {
      if (token!=null && token.isNotEmpty) break;
      final raw=prefs.getString(key);
      if (raw==null || raw.isEmpty) continue;
      try {
        final obj=jsonDecode(raw);
        if (obj is Map) {
          final nested=obj['data'];
          final found=obj['api_token'] ?? obj['token'] ??
              (nested is Map ? nested['api_token'] ?? nested['token'] : null);
          if (found is String && found.isNotEmpty) token=found;
        }
      } catch (_) {}
    }
    _sessionToken=token;
  }

  static const apiBase = 'https://careerdefenceacademy.com/api';
  Future<Map<String, dynamic>> _request(String endpoint,
      {Map<String, String>? query, Map<String, dynamic>? payload}) async {
    await _loadLoginToken();
    final uri = Uri.parse('$apiBase/$endpoint').replace(queryParameters: query);
    final headers = <String, String>{
      'Accept': 'application/json',
      ...widget.authHeaders,
      if (_sessionToken != null && _sessionToken!.isNotEmpty)
        'Authorization': 'Bearer $_sessionToken',
      if (payload != null) 'Content-Type': 'application/json',
    };
    final http.Response response = payload == null
        ? await http.get(uri, headers: headers).timeout(const Duration(seconds: 30))
        : await http.post(uri, headers: headers, body: jsonEncode(payload))
            .timeout(const Duration(seconds: 30));
    dynamic parsed;
    try { parsed = jsonDecode(response.body); }
    catch (_) { throw Exception('Non-JSON API response (HTTP ${response.statusCode}). Check route /api/$endpoint.'); }
    if (parsed is! Map) throw Exception('Unexpected API response');
    final result = Map<String, dynamic>.from(parsed);
    if (response.statusCode == 401) {
      throw Exception('Login required. Please log in again and save the api_token returned by login API.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300 || result['error'] == true) {
      throw Exception('${result['message'] ?? 'API failed'} (HTTP ${response.statusCode})');
    }
    return result;
  }

  bool _reloadRequested = false;
  Future<void> _load() async {
    if (_loading) {
      _reloadRequested = true;
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _request('mobileAppointments', query: _params());
      final list = (response['data'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final p = response['pagination'] as Map? ?? {};
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(list);
        _total = int.tryParse('${p['total']}') ?? list.length;
        _totalPages = int.tryParse('${p['total_pages']}') ?? 1;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
      if (_reloadRequested && mounted) {
        _reloadRequested = false;
        _load();
      }
    }
  }

  void _refreshFilters() {
    _page = 1;
    _load();
  }

  String _value(dynamic v) => v == null || '$v'.trim().isEmpty ? '—' : '$v';
  String _branchName(dynamic id) =>
      const {'1': 'Ambala', '2': 'Patiala', '3': 'Yamunanagar', '4': 'Mohali'}['$id'] ??
      'Other';
  String _statusName(dynamic id) => statuses.entries
      .firstWhere((e) => e.value == '$id',
          orElse: () => const MapEntry('Unknown', ''))
      .key;

  Future<void> _history(Map<String, dynamic> item) async {
    showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
              title: Text('History • ${_value(item['student_name'])}'),
              content: SizedBox(
                  width: double.maxFinite,
                  height: 420,
                  child: FutureBuilder<Map<String, dynamic>>(
                      future: _request(
                          'mobileAppointmentHistory', query: {'id': '${item['id']}'}),
                      builder: (context, snap) {
                        if (!snap.hasData)
                          return Center(
                              child: snap.hasError
                                  ? Text('${snap.error}')
                                  : const CircularProgressIndicator());
                        final rows = snap.data!['data'] as List? ?? [];
                        if (rows.isEmpty)
                          return const Center(
                              child: Text('No remarks or follow-ups'));
                        return ListView.separated(
                            itemCount: rows.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, i) {
                              final row = rows[i] as Map;
                              return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(_value(row['remark']),
                                      style: const TextStyle(fontSize: 15)),
                                  subtitle: Text(
                                      '${_value(row['remark_type'])} • ${_value(row['created'])}\nFollow-up: ${_value(row['followup_date'])} • By: ${_value(row['added_by'])}'));
                            });
                      })),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text('Close'))
              ],
            ));
  }

  Future<void> _addRemark(Map<String, dynamic> item) async {
    final remark = TextEditingController();
    String type = 'remark';
    DateTime? followup;
    bool saving = false;
    await showDialog<void>(
        context: context,
        builder: (dialogCtx) => StatefulBuilder(
            builder: (context, modalSet) => AlertDialog(
                  title: Text('Add Remark • ${_value(item['student_name'])}'),
                  content: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: remark,
                        maxLines: 4,
                        decoration: const InputDecoration(
                            labelText: 'Remark', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                        value: type,
                        isExpanded: true,
                        decoration: const InputDecoration(
                            labelText: 'Remark type',
                            border: OutlineInputBorder()),
                        items: [
                          'remark',
                          'followup',
                          'call',
                          'completed',
                          'other'
                        ]
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => modalSet(() => type = v!)),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                        onPressed: saving
                            ? null
                            : () async {
                                final d = await showDatePicker(
                                    context: dialogCtx,
                                    initialDate: followup ?? DateTime.now(),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100));
                                if (d != null) modalSet(() => followup = d);
                              },
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(followup == null
                            ? 'Optional follow-up date'
                            : DateFormat('dd MMM yyyy').format(followup!))),
                  ])),
                  actions: [
                    TextButton(
                        onPressed:
                            saving ? null : () => Navigator.pop(dialogCtx),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (remark.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Enter a remark')));
                                  return;
                                }
                                if (type == 'followup' && followup == null) {
                                  ScaffoldMessenger.of(this.context).showSnackBar(
                                      const SnackBar(content: Text('Select follow-up date')));
                                  return;
                                }
                                modalSet(() => saving = true);
                                try {
                                  await _request('mobileAppointmentRemark', payload: {
                                    'id': item['id'],
                                    'remark': remark.text.trim(),
                                    'remark_type': type,
                                    if (followup != null)
                                      'followup_date': DateFormat('yyyy-MM-dd').format(followup!),
                                  });
                                  if (dialogCtx.mounted)
                                    Navigator.pop(dialogCtx);
                                  if (mounted) {
                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(const SnackBar(
                                            content: Text('Remark saved')));
                                    _load();
                                  }
                                } catch (e) {
                                  if (mounted)
                                    ScaffoldMessenger.of(this.context)
                                        .showSnackBar(
                                            SnackBar(content: Text('$e')));
                                  if (dialogCtx.mounted)
                                    modalSet(() => saving = false);
                                }
                              },
                        child: Text(saving ? 'Saving...' : 'Save'))
                  ],
                )));
    remark.dispose();
  }

  Widget _dropdown(String label, String value, List<String> options,
          ValueChanged<String> onChange) =>
      DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          items: options
              .map((x) => DropdownMenuItem(
                  value: x, child: Text(x, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChange(v);
          });

  Widget _appointment(Map<String, dynamic> a) {
    final latest = a['latest_history'] as Map?;
    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
            padding: const EdgeInsets.all(15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                    child: Text(_value(a['student_name']),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                Chip(
                    label: Text(_statusName(a['visit_status']),
                        style: const TextStyle(fontSize: 11)))
              ]),
              Text(
                  'Father: ${_value(a['father_name'])}    Class: ${_value(a['class'])}',
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 5),
              Text(
                  '📍 ${_branchName(a['school_id'])}     ☎ ${_value(a['contact_no'])}',
                  style: const TextStyle(fontSize: 14)),
              if (_value(a['contact_no2']) != '—')
                Text('Other contact: ${_value(a['contact_no2'])}'),
              Text(
                  'Course: ${_value(a['course'])}   Interested: ${_value(a['interested'])}'),
              Text(
                  'Visit: ${_value(a['visit_date'])}  ${_value(a['time_slot'])}',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                  'Total Fees: ₹${_value(a['total_fees'])}   Received: ₹${_value(a['received_amount'])}'),
              if (latest != null)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        'Last remark: ${_value(latest['remark'])}\nNext follow-up: ${_value(latest['followup_date'])}',
                        style: const TextStyle(color: Colors.blueGrey))),
              const Divider(),
              Wrap(spacing: 8, children: [
                OutlinedButton.icon(
                    onPressed: () => _history(a),
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('History')),
                FilledButton.icon(
                    onPressed: () => _addRemark(a),
                    icon: const Icon(Icons.edit_note, size: 18),
                    label: const Text('Add Remark')),
              ])
            ])));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Appointments'),
            backgroundColor: const Color(0xFF2358A8),
            foregroundColor: Colors.white,
            actions: [
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
            ]),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                TextField(
                    controller: _search,
                    onSubmitted: (_) => _refreshFilters(),
                    decoration: InputDecoration(
                        hintText: 'Student, father or mobile',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                            onPressed: _refreshFilters,
                            icon: const Icon(Icons.arrow_forward)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _dropdown('Branch', _branch,
                          ['All', 'Ambala', 'Patiala', 'Yamunanagar', 'Mohali'], (v) {
                    setState(() => _branch = v);
                    _refreshFilters();
                  })),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _dropdown(
                          'Status', _status, statuses.keys.toList(), (v) {
                    setState(() => _status = v);
                    _refreshFilters();
                  }))
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _dropdown('Created', _period, [
                    'All records',
                    'Today',
                    'Yesterday',
                    'This week',
                    'Last week',
                    'This month',
                    'Last month'
                  ], (v) {
                    setState(() => _period = v);
                    _refreshFilters();
                  })),
                  const SizedBox(width: 8),
                  Expanded(
                      child: CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Today's follow-ups",
                              style: TextStyle(fontSize: 12)),
                          value: _todayFollowups,
                          onChanged: (v) {
                            setState(() => _todayFollowups = v ?? false);
                            _refreshFilters();
                          }))
                ]),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Total appointments: $_total',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
              ])),
          Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(_error!, textAlign: TextAlign.center),
                          TextButton(
                              onPressed: _load, child: const Text('Retry'))
                        ]))
                      : _items.isEmpty
                          ? const Center(child: Text('No appointments found'))
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  itemCount: _items.length,
                                  itemBuilder: (context, i) =>
                                      _appointment(_items[i])))),
          if (_totalPages > 1)
            Padding(
                padding: const EdgeInsets.all(8),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                      onPressed: _page > 1 && !_loading
                          ? () {
                              _page--;
                              _load();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left)),
                  Text('Page $_page of $_totalPages'),
                  IconButton(
                      onPressed: _page < _totalPages && !_loading
                          ? () {
                              _page++;
                              _load();
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right)),
                ]))
        ]),
      );
}
