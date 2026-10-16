import 'package:flutter/material.dart';

import '../app.dart';
import '../models/lead.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/primary_button.dart';

/// Pops with [lead] carrying the saved notes, or with nothing on Cancel.
class AddNotesScreen extends StatefulWidget {
  const AddNotesScreen({
    super.key,
    required this.employeeName,
    required this.lead,
  });

  final String employeeName;
  final NewLead lead;

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  late final _notes = TextEditingController(text: widget.lead.notes ?? '');
  bool _saving = false;

  bool get _editing => widget.lead.notes != null;

  bool get _canSave => _notes.text.trim() != (widget.lead.notes ?? '');

  @override
  void initState() {
    super.initState();
    _notes.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    FocusScope.of(context).unfocus();
    final updated = widget.lead.withNotes(_notes.text);
    setState(() => _saving = true);
    try {
      await AppServices.of(context).repository
          .saveNotes(updated.leadId, updated.notes);
      if (mounted) Navigator.of(context).pop(updated);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't save the notes. Check the connection and try again.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    return Scaffold(
      body: Column(
        children: [
          AppHeader(employeeName: widget.employeeName),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _editing ? 'Edit Notes' : 'Add Notes',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.body,
                          textStyle: const TextStyle(
                            fontFamily: appFontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.greenTint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD5EAC4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            lead.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lead.fullName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                lead.emailAddress,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.body,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'CONVERSATION NOTES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Semantics(
                      label: 'Conversation notes',
                      child: TextField(
                        controller: _notes,
                        autofocus: true,
                        expands: true,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 17, height: 1.45),
                        decoration: const InputDecoration(
                          hintText:
                              'What did you talk about? Anything to follow '
                              'up on?',
                          contentPadding: EdgeInsets.all(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(22, 16, 22, 16),
              child: PrimaryButton(
                label: 'Save Notes',
                busy: _saving,
                onPressed: _canSave ? _save : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
