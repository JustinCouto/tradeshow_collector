import 'package:flutter/material.dart';

import '../app.dart';
import '../models/lead.dart';
import '../theme.dart';
import '../validation.dart';
import '../widgets/app_header.dart';
import '../widgets/primary_button.dart';

/// Pops with the saved [NewLead], or with nothing on Cancel.
class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key, required this.employeeName});

  final String employeeName;

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _company = TextEditingController();
  final _email = TextEditingController();
  final _emailFocus = FocusNode();

  /// The email error waits until the employee has left the field once, so it
  /// doesn't flash while they are still typing.
  bool _emailTouched = false;
  bool _saving = false;

  bool get _canSave => canSaveLead(
    firstName: _firstName.text,
    lastName: _lastName.text,
    emailAddress: _email.text,
  );

  String? get _emailError {
    final text = _email.text.trim();
    if (!_emailTouched || text.isEmpty || isValidEmail(text)) return null;
    return 'Enter a valid email, like name@company.com';
  }

  @override
  void initState() {
    super.initState();
    for (final c in [_firstName, _lastName, _company, _email]) {
      c.addListener(_refresh);
    }
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus && _email.text.trim().isNotEmpty) {
        setState(() => _emailTouched = true);
      }
    });
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _company, _email]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    FocusScope.of(context).unfocus();
    final lead = NewLead(
      firstName: _firstName.text,
      lastName: _lastName.text,
      companyName: _company.text,
      emailAddress: _email.text,
    );
    setState(() => _saving = true);
    try {
      await AppServices.of(context).repository
          .addLead(lead, employeeName: widget.employeeName);
      if (mounted) Navigator.of(context).pop(lead);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't save the lead. Check the connection and try again.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(employeeName: widget.employeeName),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'New Lead',
                        style: TextStyle(
                          fontSize: 30,
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
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'First name',
                        required: true,
                        controller: _firstName,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.givenName],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _Field(
                        label: 'Last name',
                        required: true,
                        controller: _lastName,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.familyName],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _Field(
                  label: 'Company',
                  controller: _company,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.organizationName],
                ),
                const SizedBox(height: 18),
                _Field(
                  label: 'Email address',
                  required: true,
                  controller: _email,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  errorText: _emailError,
                  onSubmitted: (_) {
                    setState(() => _emailTouched = true);
                    _save();
                  },
                ),
                const SizedBox(height: 18),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '* ',
                        style: TextStyle(
                          color: AppColors.greenText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: 'Required to save'),
                    ],
                  ),
                  style: TextStyle(color: AppColors.muted, fontSize: 14),
                ),
              ],
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
                label: 'Save Lead',
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.required = false,
    this.autofocus = false,
    this.focusNode,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.errorText,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool required;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  static OutlineInputBorder _border(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.greenText),
                )
              else
                const TextSpan(
                  text: ' (optional)',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          style: const TextStyle(
            color: AppColors.body,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            autocorrect: keyboardType != TextInputType.emailAddress,
            onSubmitted: onSubmitted,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            // The error is drawn below as plain text so it can wrap and line
            // up with the field edge like the mockup.
            decoration: hasError
                ? InputDecoration(
                    fillColor: AppColors.errorFill,
                    enabledBorder: _border(AppColors.errorBorder, 1),
                    focusedBorder: _border(AppColors.errorBorder, 1.5),
                  )
                : const InputDecoration(),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
