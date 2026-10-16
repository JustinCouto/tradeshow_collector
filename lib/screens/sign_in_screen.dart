import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

  /// Whether the suggestion list is open, so the field can join its outline.
  bool get _showingSuggestions =>
      _nameFocus.hasFocus &&
      matchEmployeeNames(_knownNames, _name.text).isNotEmpty;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _nameFocus.addListener(() => setState(() {}));
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
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _SoftCircle(
            center: Offset(size.width * 0.5, size.height * 0.36),
            radius: size.width * 0.62,
            color: const Color(0x80E3F2D7),
            solidUntil: 0,
          ),
          const _FloatingCircles(),
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
                        const Spacer(),
                        Center(
                          child: SoCreateLogo(
                            width: math.min(360, constraints.maxWidth * 0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
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
                          'Sign-up Capture',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const Spacer(),
                        _SignInPanel(
                          bottomInset: bottomInset,
                          children: [
                            const Text(
                              'Team Member',
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
                                      _NameField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        joinedToSuggestions:
                                            _showingSuggestions,
                                        // Submits what was typed rather than the first
                                        // suggestion, so a new "Mark" isn't turned into an
                                        // existing "Mark Chen".
                                        onSubmitted: _continue,
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
                              trailingIcon: Icons.arrow_forward,
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

/// Pale green circles that drift slowly and bounce off the screen edges.
/// They hold still when the device asks for reduced motion.
class _FloatingCircles extends StatefulWidget {
  const _FloatingCircles();

  @override
  State<_FloatingCircles> createState() => _FloatingCirclesState();
}

class _FloatingCirclesState extends State<_FloatingCircles>
    with SingleTickerProviderStateMixin {
  /// Starting centers as fractions of the screen, radii as fractions of its
  /// width.
  static const _seeds = [
    (x: 0.92, y: 0.06, r: 0.196),
    (x: 0.04, y: 0.14, r: 0.14),
    (x: 0.0, y: 0.55, r: 0.161),
    (x: 1.0, y: 0.63, r: 0.14),
    (x: 0.55, y: 0.04, r: 0.07),
    (x: 0.3, y: 0.42, r: 0.098),
    (x: 0.75, y: 0.85, r: 0.231),
  ];

  /// Pixels per second for the slowest circle; each next one is 10% faster.
  static const _baseSpeed = 16.0;
  static const _speedStep = 1.1;

  static const _color = Color(0xFFD9EEC6);

  late final Ticker _ticker = createTicker(_tick);
  final _random = math.Random();
  late final List<Offset> _velocities = [
    for (var i = 0; i < _seeds.length; i++)
      _randomVelocity(_baseSpeed * math.pow(_speedStep, i)),
  ];
  List<Offset>? _centers;
  Size _size = Size.zero;
  Duration _lastTick = Duration.zero;

  Offset _randomVelocity(double speed) {
    final angle = _random.nextDouble() * 2 * math.pi;
    return Offset.fromDirection(angle, speed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still && _ticker.isActive) {
      _ticker.stop();
    } else if (!still && !_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final centers = _centers;
    if (centers == null) return;
    setState(() {
      for (var i = 0; i < centers.length; i++) {
        final r = _seeds[i].r * _size.width;
        var v = _velocities[i];
        final c = centers[i] + v * dt;
        // Only flip when heading outward, so circles that start partly
        // off-screen drift back in instead of getting stuck at the edge.
        if ((c.dx - r < 0 && v.dx < 0) ||
            (c.dx + r > _size.width && v.dx > 0)) {
          v = Offset(-v.dx, v.dy);
        }
        if ((c.dy - r < 0 && v.dy < 0) ||
            (c.dy + r > _size.height && v.dy > 0)) {
          v = Offset(v.dx, -v.dy);
        }
        _velocities[i] = v;
        centers[i] = c;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final old = _centers;
          if (old == null) {
            _centers = [
              for (final s in _seeds)
                Offset(s.x * size.width, s.y * size.height),
            ];
          } else if (size != _size && !_size.isEmpty) {
            // Keep each circle in the same relative spot after a resize.
            _centers = [
              for (final c in old)
                Offset(
                  c.dx / _size.width * size.width,
                  c.dy / _size.height * size.height,
                ),
            ];
          }
          _size = size;
          return Stack(
            children: [
              for (var i = 0; i < _seeds.length; i++)
                _SoftCircle(
                  center: _centers![i],
                  radius: _seeds[i].r * size.width,
                  color: _color,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Pale green circle whose edge fades into the white background.
class _SoftCircle extends StatelessWidget {
  const _SoftCircle({
    required this.center,
    required this.radius,
    this.color = const Color(0xFFE8F4DE),
    this.solidUntil = 0.8,
  });

  final Offset center;
  final double radius;
  final Color color;

  /// Fraction of the radius drawn at full [color] before the fade begins.
  final double solidUntil;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - radius,
      top: center.dy - radius,
      width: radius * 2,
      height: radius * 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color, color.withValues(alpha: 0)],
            stops: [0, solidUntil, 1],
          ),
        ),
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
      child: CustomPaint(
        foregroundPainter: const _OpenOutlinePainter(openTop: false),
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(_fieldRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 10),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 15, color: AppColors.muted),
                    SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SIGNED IN BEFORE? TAP YOUR NAME',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 248),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, i) {
                      final name = options[i];
                      return InkWell(
                        onTap: () => onSelected(name),
                        child: Container(
                          color: i == highlighted
                              ? const Color(0xFFF3F9EE)
                              : null,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              _InitialsAvatar(name),
                              const SizedBox(width: 14),
                              Expanded(child: _HighlightedName(name, query)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
            ],
          ),
        ),
      ),
    );
  }
}

const _fieldRadius = 14.0;

/// The name field. While suggestions are showing it drops its top edge so it
/// and the list above read as one outlined box.
class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.focusNode,
    required this.joinedToSuggestions,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool joinedToSuggestions;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final joined = joinedToSuggestions;
    return CustomPaint(
      foregroundPainter: joined
          ? const _OpenOutlinePainter(openTop: true)
          : null,
      child: ClipRRect(
        borderRadius: joined
            ? const BorderRadius.vertical(bottom: Radius.circular(_fieldRadius))
            : BorderRadius.circular(_fieldRadius),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.go,
          autocorrect: false,
          autofillHints: const [AutofillHints.name],
          style: const TextStyle(fontSize: 17),
          decoration: InputDecoration(
            hintText: 'ex: Jr. Couto',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 6),
              child: Icon(Icons.person_outline, color: AppColors.muted),
            ),
            enabledBorder: joined ? InputBorder.none : null,
            focusedBorder: joined ? InputBorder.none : null,
          ),
          onSubmitted: (_) => onSubmitted(),
        ),
      ),
    );
  }
}

/// Green rounded outline with one edge left open, used to join the
/// suggestion list (open at the bottom) to the field (open at the top).
class _OpenOutlinePainter extends CustomPainter {
  const _OpenOutlinePainter({required this.openTop});

  final bool openTop;

  static const _stroke = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    if (openTop) {
      canvas.translate(0, size.height);
      canvas.scale(1, -1);
    }
    const inset = _stroke / 2;
    const r = Radius.circular(_fieldRadius - inset);
    final left = inset;
    final right = size.width - inset;
    final top = inset;
    final bottom = size.height;
    final path = Path()
      ..moveTo(left, bottom)
      ..lineTo(left, top + r.y)
      ..arcToPoint(Offset(left + r.x, top), radius: r)
      ..lineTo(right - r.x, top)
      ..arcToPoint(Offset(right, top + r.y), radius: r)
      ..lineTo(right, bottom);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );
  }

  @override
  bool shouldRepaint(_OpenOutlinePainter old) => old.openTop != openTop;
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar(this.name);

  final String name;

  String get _initials {
    final words = name.trim().split(RegExp(r'\s+'));
    final first = words.first.isEmpty ? '' : words.first[0];
    final last = words.length > 1 ? words.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.navy,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
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
