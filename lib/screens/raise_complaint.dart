import 'dart:convert';

import 'dart:io';

import 'package:careerapp/services/api_services.dart';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:video_player/video_player.dart';

class RaiseComplaintScreen extends StatefulWidget {
  const RaiseComplaintScreen({Key? key}) : super(key: key);

  @override
  State<RaiseComplaintScreen> createState() => _RaiseComplaintScreenState();
}

class _RaiseComplaintScreenState extends State<RaiseComplaintScreen> {
  static const _primary = Color(0xFF4F46E5);

  static const _branches = ['Ambala', 'Yamunanagar', 'Patiala'];

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _remarksController = TextEditingController();

  final _picker = ImagePicker();

  String? _branch;

  String _userId = '';

  File? _photo;

  File? _video;

  List<dynamic> _tickets = [];

  bool _loading = true;

  bool _submitting = false;

  String? _error;

  @override
  void initState() {
    super.initState();

    _loadUserAndTickets();
  }

  @override
  void dispose() {
    _nameController.dispose();

    _remarksController.dispose();

    super.dispose();
  }

  String get _guestTicketCacheKey =>
      'complaint_guest_tickets_${_userId.isEmpty || _userId == '0' ? 'anon' : _userId}';

  Future<void> _loadUserAndTickets() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic>? account;
      for (final key in ['staffData', 'consulData', 'userData']) {
        final raw = prefs.getString(key);
        if (raw == null || raw.trim().isEmpty) continue;
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            account = Map<String, dynamic>.from(decoded);
            break;
          }
        } catch (_) {
          // Invalid cached profile data should not block guest mode.
        }
      }
      _userId = (account?['user_id'] ?? account?['id'] ?? '').toString();
      if (_nameController.text.isEmpty) {
        _nameController.text =
            (account?['name'] ?? account?['user_name'] ?? '').toString();
      }

      // This API identifies signed-in users from its PHP session, not a query ID.
      final response = await ApiService.getComplaintTickets();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Unable to load tickets (HTTP ${response.statusCode})');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map ||
          decoded['success'] == false ||
          decoded['error'] == true) {
        throw Exception(decoded is Map
            ? (decoded['message'] ?? 'Unable to load tickets').toString()
            : 'Invalid response');
      }
      final rawTickets =
          decoded['data'] ?? decoded['tickets'] ?? decoded['complaints'];
      List<dynamic> tickets = rawTickets is List ? rawTickets : <dynamic>[];
      if (decoded['guest'] == true) {
        final cached = prefs.getString(_guestTicketCacheKey);
        if (cached != null) {
          final localTickets = jsonDecode(cached);
          if (localTickets is List) tickets = localTickets;
        }
      }
      if (mounted) setState(() => _tickets = tickets);
    } catch (e) {
      // Keep the form usable even if ticket history is temporarily unavailable.
      if (mounted) {
        setState(() {
          _tickets = [];
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null && mounted) setState(() => _photo = File(picked.path));
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Unable to open camera/gallery: $error');
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final picked = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 3),
      );
      if (picked != null && mounted) setState(() => _video = File(picked.path));
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Unable to record/select video: $error');
      }
    }
  }

  Future<void> _submitComplaint() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_branch == null || _branch!.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Please select a branch');
      return;
    }

    setState(() => _submitting = true);
    final submittedName = _nameController.text.trim().isEmpty
        ? 'Guest'
        : _nameController.text.trim();
    final submittedBranch = _branch!;
    final submittedRemarks = _remarksController.text.trim();
    try {
      final files = <String, File>{};
      if (_photo != null) {
        if (!await _photo!.exists()) {
          throw Exception('Selected photo is unavailable.');
        }
        if (await _photo!.length() > 10 * 1024 * 1024) {
          throw Exception('Photo must be smaller than 10 MB.');
        }
        files['photo_proof'] = _photo!;
      }
      if (_video != null) {
        if (!await _video!.exists()) {
          throw Exception('Selected video is unavailable.');
        }
        if (await _video!.length() > 50 * 1024 * 1024) {
          throw Exception('Video must be smaller than 50 MB.');
        }
        files['video_proof'] = _video!;
      }

      final result = await ApiService.postComplaintWithFiles({
        // API requires a name, so an empty optional name is submitted as Guest.
        'name': submittedName,
        'branch': submittedBranch,
        'remarks': submittedRemarks,
      }, files);

      final saved = result['success'] == true ||
          result['error'] == false ||
          result['status'].toString() == '1';
      if (!saved) {
        throw Exception(
            (result['message'] ?? 'Complaint was not saved').toString());
      }
      if (!mounted) return;
      _remarksController.clear();
      setState(() {
        _photo = null;
        _video = null;
        _branch = null;
      });
      final ticketNo = (result['ticket_no'] ?? '').toString();
      Fluttertoast.showToast(
        msg: ticketNo.isNotEmpty
            ? 'Complaint submitted: $ticketNo'
            : (result['message'] ?? 'Complaint submitted successfully')
                .toString(),
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      if (result['guest'] == true) {
        final responseData = result['data'];
        final ticket = responseData is Map
            ? Map<String, dynamic>.from(responseData)
            : <String, dynamic>{};
        ticket['ticket_no'] = ticket['ticket_no'] ?? ticketNo;
        ticket['name'] = ticket['name'] ?? submittedName;
        ticket['branch'] = ticket['branch'] ?? submittedBranch;
        ticket['remarks'] = ticket['remarks'] ?? submittedRemarks;
        ticket['status'] = ticket['status'] ?? 'Pending';
        ticket['created_at'] ??= DateTime.now().toIso8601String();
        final prefs = await SharedPreferences.getInstance();
        final updatedTickets = <dynamic>[ticket, ..._tickets];
        await prefs.setString(_guestTicketCacheKey, jsonEncode(updatedTickets));
        if (mounted) setState(() => _tickets = updatedTickets);
      } else {
        await _loadUserAndTickets();
      }
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: error.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Raise Complaint',
            style: TextStyle(fontWeight: FontWeight.w700)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh tickets',
            onPressed: _loading ? null : _loadUserAndTickets,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserAndTickets,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          children: [
            _buildIntroCard(),
            const SizedBox(height: 16),
            _buildComplaintForm(),
            const SizedBox(height: 24),
            _buildTicketHeader(),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(28),
                child:
                    Center(child: CircularProgressIndicator(color: _primary)),
              )
            else if (_error != null)
              _buildError()
            else if (_tickets.isEmpty)
              _buildEmptyTickets()
            else
              ..._tickets.map(_buildTicketCard),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [_primary, Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(.2),
              blurRadius: 14,
              offset: const Offset(0, 6)),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: Icon(Icons.support_agent_rounded,
                color: Colors.white, size: 28),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('We are here to help',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Share the issue and attach proof if available.',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintForm() {
    return _surface(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeading(Icons.edit_note_rounded, 'New complaint'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration('Name (optional)', Icons.person_outline),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _branch,
              decoration:
                  _decoration('Select branch', Icons.location_on_outlined),
              hint: const Text('Choose the branch related to this complaint'),
              isExpanded: true,
              items: _branches
                  .map((branch) =>
                      DropdownMenuItem(value: branch, child: Text(branch)))
                  .toList(),
              onChanged: (value) => setState(() => _branch = value),
              validator: (value) =>
                  value == null ? 'Please select a branch' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _remarksController,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: _decoration(
                  'Remarks / describe the issue', Icons.notes_rounded),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please describe your complaint'
                  : null,
            ),
            const SizedBox(height: 16),
            const Text('Photo proof (optional)',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _proofButton(Icons.camera_alt_outlined, 'Take photo',
                        () => _pickPhoto(ImageSource.camera))),
                const SizedBox(width: 10),
                Expanded(
                    child: _proofButton(Icons.photo_library_outlined,
                        'Choose photo', () => _pickPhoto(ImageSource.gallery))),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Video proof (optional)',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _proofButton(Icons.videocam_outlined, 'Record video',
                        () => _pickVideo(ImageSource.camera))),
                const SizedBox(width: 10),
                Expanded(
                    child: _proofButton(Icons.video_library_outlined,
                        'Choose video', () => _pickVideo(ImageSource.gallery))),
              ],
            ),
            if (_photo != null)
              _selectedFile(
                  _photo!, 'Photo', () => setState(() => _photo = null)),
            if (_video != null)
              _selectedFile(
                  _video!, 'Video', () => setState(() => _video = null)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submitComplaint,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(_submitting ? 'Submitting...' : 'Submit complaint'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketHeader() => Row(
        children: [
          const Expanded(
              child: Text('Your tickets',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033)))),
          if (!_loading && _error == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${_tickets.length} total',
                  style: const TextStyle(
                      color: _primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      );

  Widget _buildTicketCard(dynamic ticket) {
    final item = ticket is Map ? ticket : <String, dynamic>{};

    final status = (item['status'] ?? 'Pending').toString();

    final normalized = status
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');

    final color = normalized == 'resolved' || normalized == 'closed'
        ? const Color(0xFF15966A)
        : normalized == 'inprogress' || normalized == 'processing'
            ? const Color(0xFF2563EB)
            : const Color(0xFFD97706);
    final stage = normalized == 'resolved' || normalized == 'closed'
        ? 2
        : normalized == 'inprogress' || normalized == 'processing'
            ? 1
            : 0;

    final ticketNo =
        (item['ticket_no'] ?? item['ticket_id'] ?? item['id'] ?? '').toString();

    final branch = (item['branch'] ?? '').toString();

    final remarks = (item['remarks'] ?? item['complaint'] ?? '').toString();

    final name = (item['name'] ?? '').toString();

    final created = _formatDate(item['created_at'] ?? item['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _surface(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.confirmation_number_outlined,
                    color: _primary, size: 19),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        ticketNo.isEmpty
                            ? 'Complaint ticket'
                            : 'Ticket #$ticketNo',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B)))),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: color.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(status,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildTrackingTimeline(stage),
            const SizedBox(height: 12),
            Wrap(spacing: 14, runSpacing: 7, children: [
              if (branch.isNotEmpty) _meta(Icons.location_on_outlined, branch),
              if (name.isNotEmpty) _meta(Icons.person_outline, name),
              if (created.isNotEmpty) _meta(Icons.schedule_rounded, created),
            ]),
            if (remarks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(remarks,
                  style:
                      const TextStyle(color: Color(0xFF475569), height: 1.4)),
            ],
            if ((item['photo_proof'] ?? '').toString().isNotEmpty ||
                (item['video_proof'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if ((item['photo_proof'] ?? '').toString().isNotEmpty)
                    _proofPreview(
                      'Photo proof',
                      Image.network(
                        _proofUrl(item['photo_proof'].toString()),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _previewFallback(Icons.broken_image_outlined),
                      ),
                      () => _openImage(
                          url: _proofUrl(item['photo_proof'].toString())),
                    ),
                  if ((item['video_proof'] ?? '').toString().isNotEmpty)
                    _proofPreview(
                      'Video proof',
                      _InlineVideoFrame(
                          url: _proofUrl(item['video_proof'].toString())),
                      () => _openVideo(
                          url: _proofUrl(item['video_proof'].toString())),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline(int currentStage) {
    const labels = ['Submitted', 'In Progress', 'Resolved'];
    const icons = [
      Icons.assignment_turned_in_outlined,
      Icons.sync_rounded,
      Icons.check_circle_outline_rounded,
    ];
    const completedColor = Color(0xFF15966A);
    const activeColor = Color(0xFF4F46E5);
    const pendingColor = Color(0xFFCBD5E1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EBF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 14),
            child: Text('Complaint progress',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569))),
          ),
          Row(
            children: List.generate(labels.length, (index) {
              final isComplete = index < currentStage;
              final isCurrent = index == currentStage;
              final stepColor = isComplete
                  ? completedColor
                  : isCurrent
                      ? activeColor
                      : pendingColor;

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index > 0)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: index <= currentStage
                                  ? completedColor
                                  : pendingColor,
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isComplete
                                ? completedColor
                                : isCurrent
                                    ? activeColor
                                    : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: stepColor,
                              width: isCurrent ? 2 : 1.5,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: activeColor.withOpacity(.18),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isComplete ? Icons.check_rounded : icons[index],
                            size: 17,
                            color: isComplete || isCurrent
                                ? Colors.white
                                : pendingColor,
                          ),
                        ),
                        if (index < labels.length - 1)
                          Expanded(
                            child: Container(
                              height: 3,
                              color: index < currentStage
                                  ? completedColor
                                  : pendingColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      labels[index],
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isComplete || isCurrent
                            ? const Color(0xFF334155)
                            : const Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: isCurrent || isComplete
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildError() => _surface(
        child: Column(children: [
          const Icon(Icons.cloud_off_outlined,
              color: Color(0xFFEF4444), size: 32),
          const SizedBox(height: 8),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          OutlinedButton.icon(
              onPressed: _loadUserAndTickets,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again')),
        ]),
      );

  Widget _buildEmptyTickets() => _surface(
        child: const Column(children: [
          Icon(Icons.inbox_outlined, size: 38, color: Color(0xFF94A3B8)),
          SizedBox(height: 8),
          Text('No complaints yet',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          SizedBox(height: 4),
          Text('Submitted complaints will appear here.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        ]),
      );

  Widget _proofButton(IconData icon, String label, VoidCallback onTap) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 19),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
          side: const BorderSide(color: Color(0xFFD7D9F7)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _selectedFile(File file, String type, VoidCallback remove) =>
      Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _proofPreview(
              type,
              type == 'Photo'
                  ? Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _previewFallback(Icons.broken_image_outlined),
                    )
                  : _InlineVideoFrame(file: file),
              () => type == 'Photo'
                  ? _openImage(file: file)
                  : _openVideo(file: file),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                file.path.split(Platform.pathSeparator).last,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            IconButton(
              onPressed: remove,
              visualDensity: VisualDensity.compact,
              tooltip: 'Remove $type proof',
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      );
  Widget _surface(
          {required Widget child,
          EdgeInsets padding = const EdgeInsets.all(18)}) =>
      Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8EBF3)),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF172033).withOpacity(.045),
                blurRadius: 14,
                offset: const Offset(0, 4))
          ],
        ),
        child: child,
      );

  Widget _sectionHeading(IconData icon, String title) => Row(children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _primary, size: 20)),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033))),
      ]);

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 1.5)),
      );

  Widget _meta(IconData icon, String text) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ]);

  Widget _proofPreview(String label, Widget preview, VoidCallback onTap) =>
      SizedBox(
        width: 112,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  width: 112,
                  height: 76,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      preview,
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.open_in_full_rounded,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _previewFallback(IconData icon) => Container(
        color: const Color(0xFFE2E8F0),
        alignment: Alignment.center,
        child: Icon(icon, color: const Color(0xFF64748B)),
      );

  String _proofUrl(String fileName) {
    if (fileName.startsWith('http://') || fileName.startsWith('https://')) {
      return fileName;
    }
    return '${ApiService.careerdefenceacademy2}uploads/complaint_proofs/${Uri.encodeComponent(fileName)}';
  }

  Future<void> _openImage({File? file, String? url}) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: .7,
                maxScale: 4,
                child: file != null
                    ? Image.file(file, fit: BoxFit.contain)
                    : Image.network(url!, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton.filled(
                onPressed: () => Navigator.pop(dialogContext),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openVideo({File? file, String? url}) async {
    final controller = file != null
        ? VideoPlayerController.file(file)
        : VideoPlayerController.networkUrl(Uri.parse(url!));
    try {
      await controller.initialize();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                            }
                          });
                        },
                        icon: Icon(controller.value.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill),
                      ),
                      Expanded(
                        child: VideoProgressIndicator(controller,
                            allowScrubbing: true),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Unable to open video: $error');
      }
    } finally {
      await controller.dispose();
    }
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return '';

    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(value.toString()));
    } catch (_) {
      return value.toString();
    }
  }
}

class _InlineVideoFrame extends StatefulWidget {
  const _InlineVideoFrame({this.file, this.url});

  final File? file;
  final String? url;

  @override
  State<_InlineVideoFrame> createState() => _InlineVideoFrameState();
}

class _InlineVideoFrameState extends State<_InlineVideoFrame> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = widget.file != null
          ? VideoPlayerController.file(widget.file!)
          : VideoPlayerController.networkUrl(Uri.parse(widget.url!));
      _controller = controller;
      await controller.initialize();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed || controller == null || !controller.value.isInitialized) {
      return Container(
        color: const Color(0xFF1E293B),
        alignment: Alignment.center,
        child: const Icon(Icons.play_circle_outline,
            size: 30, color: Colors.white70),
      );
    }
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }
}
