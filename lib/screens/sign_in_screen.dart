import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app.dart';
import '../employee_names.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/socreate_logo.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _name = TextEditingController();
  final _nameFocus = FocusNode();
  bool _submitting = false;

  /// Everyone who has saved a lead. Stays empty if the list can't be loaded,
  /// in which case the field works as plain text entry.
  List<String> _knownNames = const [];
  bool _started = false;

  bool get _canContinue => _name.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _loadNames();
    }
  }

  Future<void> _loadNames() async {
    try {
      final names = await AppServices.of(context).repository
          .fetchEmployeeNames();
      if (mounted) setState(() => _knownNames = names);
    } catch (_) {
      // Suggestions are a convenience; sign-in still works without them.
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_canContinue || _submitting) return;
    setState(() => _submitting = true);
    await AppServices.of(context).session
        .signIn(canonicalEmployeeName(_knownNames, _name.text));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -screenHeight * 0.17,
            height: screenHeight * 1.37,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/sign_in_background.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              excludeFromSemantics: true,
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x40FFFFFF),
                  Color(0x59FFFFFF),
                  Color(0xCCFFFFFF),
                  Color(0xDEFFFFFF),
                  Color(0xE6FFFFFF),
                ],
                stops: [0, 0.15, 0.36, 0.65, 1],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 5),
                        Center(
                          child: SoCreateLogo(
                            width: math.min(400, constraints.maxWidth * 0.81),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'TRADESHOW',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                            color: AppColors.greenText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Lead Capture',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Enter your name to start\ncollecting leads!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.45,
                            color: AppColors.body,
                          ),
                        ),
                        const Spacer(flex: 2),
                        _SignInPanel(
                          bottomInset: bottomInset,
                          children: [
                            const Text(
                              'Employee Name',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            RawAutocomplete<String>(
                              textEditingController: _name,
                              focusNode: _nameFocus,
                              // The keyboard covers the space below the field.
                              optionsViewOpenDirection:
                                  OptionsViewOpenDirection.up,
                              optionsBuilder: (value) =>
                                  matchEmployeeNames(_knownNames, value.text),
                              onSelected: (_) => _nameFocus.unfocus(),
                              fieldViewBuilder:
                                  (context, controller, focusNode, _) =>
                                      TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        textInputAction: TextInputAction.go,
                                        autocorrect: false,
                                        autofillHints: const [
                                          AutofillHints.name,
                                        ],
                                        style: const TextStyle(fontSize: 17),
                                        decoration: const InputDecoration(
                                          hintText: 'ex: Jr. Couto',
                                        ),
                                        // Submits what was typed rather than the first
                                        // suggestion, so a new "Mark" isn't turned into an
                                        // existing "Mark Chen".
                                        onSubmitted: (_) => _continue(),
                                      ),
                              optionsViewBuilder:
                                  (context, onSelected, options) =>
                                      _NameSuggestions(
                                        options: options.toList(),
                                        query: _name.text,
                                        onSelected: onSelected,
                                      ),
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: 'Continue',
                              height: 56,
                              busy: _submitting,
                              onPressed: _canContinue ? _continue : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded light-green sheet pinned to the bottom of the sign-in screen.
class _SignInPanel extends StatelessWidget {
  const _SignInPanel({required this.bottomInset, required this.children});

  final double bottomInset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.greenTint,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A1E2433),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(28, 12, 28, 20 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFC6E4AE),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _NameSuggestions extends StatelessWidget {
  const _NameSuggestions({
    required this.options,
    required this.query,
    required this.onSelected,
  });

  final List<String> options;
  final String query;
  final AutocompleteOnSelected<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final highlighted = AutocompleteHighlightedOption.of(context);
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Material(
          color: Colors.white,
          elevation: 6,
          shadowColor: const Color(0x331E2433),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 232),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              reverse: true,
              itemCount: options.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, i) {
                final name = options[i];
                return InkWell(
                  onTap: () => onSelected(name),
                  child: Container(
                    color: i == highlighted ? AppColors.greenTint : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _HighlightedName(name, query)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Bolds the part of [name] that matches what was typed.
class _HighlightedName extends StatelessWidget {
  const _HighlightedName(this.name, this.query);

  final String name;
  final String query;

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(fontSize: 17, color: AppColors.body);
    final q = query.trim().toLowerCase();
    final lower = name.toLowerCase();
    var start = lower.startsWith(q) ? 0 : lower.indexOf(' $q');
    if (start > 0) start += 1;
    if (q.isEmpty || start < 0) {
      return Text(name, style: base, overflow: TextOverflow.ellipsis);
    }
    final end = start + q.length;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: name.substring(0, start)),
          TextSpan(
            text: name.substring(start, end),
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: name.substring(end)),
        ],
      ),
      style: base,
      overflow: TextOverflow.ellipsis,
    );
  }
}
