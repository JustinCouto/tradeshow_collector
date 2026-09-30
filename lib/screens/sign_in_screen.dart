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
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF3F8EE)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(flex: 3),
                      const Center(child: SoCreateLogo(width: 300)),
                      const SizedBox(height: 36),
                      const Text(
                        'Tradeshow Lead Capture',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
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
                      const Spacer(flex: 4),
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
                        optionsViewOpenDirection: OptionsViewOpenDirection.up,
                        optionsBuilder: (value) =>
                            matchEmployeeNames(_knownNames, value.text),
                        onSelected: (_) => _nameFocus.unfocus(),
                        fieldViewBuilder: (context, controller, focusNode, _) =>
                            TextField(
                              controller: controller,
                              focusNode: focusNode,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.go,
                              autocorrect: false,
                              autofillHints: const [AutofillHints.name],
                              style: const TextStyle(fontSize: 17),
                              decoration: const InputDecoration(
                                hintText: 'ex: Jr. Couto',
                              ),
                              // Submits what was typed rather than the first
                              // suggestion, so a new "Mark" isn't turned into an
                              // existing "Mark Chen".
                              onSubmitted: (_) => _continue(),
                            ),
                        optionsViewBuilder: (context, onSelected, options) =>
                            _NameSuggestions(
                              options: options.toList(),
                              query: _name.text,
                              onSelected: onSelected,
                            ),
                      ),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: 'Continue',
                        busy: _submitting,
                        onPressed: _canContinue ? _continue : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
