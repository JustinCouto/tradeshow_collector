import 'package:flutter/material.dart';

import '../models/lead.dart';
import '../theme.dart';

class SavedLeadCard extends StatefulWidget {
  const SavedLeadCard({
    super.key,
    required this.lead,
    required this.onEditNotes,
  });

  final NewLead lead;
  final VoidCallback onEditNotes;

  @override
  State<SavedLeadCard> createState() => _SavedLeadCardState();
}

class _SavedLeadCardState extends State<SavedLeadCard> {
  bool _notesExpanded = false;

  @override
  void didUpdateWidget(SavedLeadCard old) {
    super.didUpdateWidget(old);
    if (old.lead.leadId != widget.lead.leadId) _notesExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final notes = lead.notes;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCDE7BA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1452A51F),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.brightGreen, size: 26),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sign-up saved',
                  style: TextStyle(
                    color: AppColors.greenText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Just now',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
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
                    if (lead.companyName != null)
                      Text(
                        lead.companyName!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.body,
                          fontSize: 16,
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
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),
          if (notes == null)
            _AddNotesLink(onTap: widget.onEditNotes)
          else
            _NotesPreview(
              notes: notes,
              expanded: _notesExpanded,
              onToggle: () => setState(() => _notesExpanded = !_notesExpanded),
              onEdit: widget.onEditNotes,
            ),
        ],
      ),
    );
  }
}

const _linkStyle = TextStyle(
  color: AppColors.greenText,
  fontSize: 15,
  fontWeight: FontWeight.w700,
);

class _AddNotesLink extends StatelessWidget {
  const _AddNotesLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.greenText),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Add Conversation Notes',
                  overflow: TextOverflow.ellipsis,
                  style: _linkStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One line of the notes with "Show more", or all of them with an edit
/// pencil and "Show less".
class _NotesPreview extends StatelessWidget {
  const _NotesPreview({
    required this.notes,
    required this.expanded,
    required this.onToggle,
    required this.onEdit,
  });

  final String notes;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  static const _textStyle = TextStyle(
    color: AppColors.body,
    fontSize: 16,
    height: 1.45,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: notes, style: _textStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();
        final showAll = expanded || !overflows;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'CONVERSATION NOTES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            if (showAll)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(notes, style: _textStyle)),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Edit notes',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.greenText,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                  ),
                ],
              )
            else
              Text(
                notes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _textStyle,
              ),
            if (overflows)
              Align(
                alignment: Alignment.centerRight,
                child: Semantics(
                  button: true,
                  child: GestureDetector(
                    onTap: onToggle,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: Text(
                        expanded ? 'Show less' : 'Show more',
                        style: _linkStyle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
