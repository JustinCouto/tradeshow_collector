import 'package:flutter/material.dart';

import '../models/lead.dart';
import '../ordinal.dart';
import '../theme.dart';

/// Shared by every row so the lead counts line up in one column.
const _countColumnWidth = 60.0;

/// Shared by every row so the names line up.
const _rankColumnWidth = 60.0;

/// About as wide as the leader's "1st", so every rank shares its center line
/// while the group sits against the left edge.
const _rankSlotWidth = 48.0;

/// Top three employees and the show-wide total. "Show all" slides open the
/// rest of the team.
class TopPerformersCard extends StatefulWidget {
  const TopPerformersCard({
    super.key,
    required this.entries,
    required this.employeeName,
  });

  /// Null while loading.
  final List<LeaderboardEntry>? entries;
  final String employeeName;

  @override
  State<TopPerformersCard> createState() => _TopPerformersCardState();
}

class _TopPerformersCardState extends State<TopPerformersCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  late final _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  )..addStatusListener((_) => setState(() {}));

  late final _revealCurve = CurvedAnimation(
    parent: _reveal,
    curve: Curves.easeInOut,
  );

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _reveal.forward() : _reveal.reverse();
  }

  @override
  void dispose() {
    _revealCurve.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = widget.employeeName;
    final all = widget.entries;
    final top = all?.take(3).toList() ?? const <LeaderboardEntry>[];
    final rest = all?.skip(3).toList() ?? const <LeaderboardEntry>[];
    final canExpand = rest.isNotEmpty;
    final expanded = _expanded && canExpand;
    final showTotal = all?.fold<int>(0, (sum, e) => sum + e.leadCount) ?? 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.divider),
        ),
        child: Stack(
          children: [
            if (top.isNotEmpty)
              Positioned(
                right: -60,
                top: -50,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: const BoxDecoration(
                    color: AppColors.greenTint,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 20, 22, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'TOP PERFORMERS',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      Text(
                        'Show totals',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (all == null)
                  const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (top.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(22, 18, 22, 24),
                    child: Text(
                      'No sign-ups yet. Be the first on the board!',
                      style: TextStyle(color: AppColors.body, fontSize: 15),
                    ),
                  )
                else ...[
                  _LeaderRow(
                    entry: top.first,
                    isMe: top.first.employeeName == employeeName,
                  ),
                  for (final entry in top.skip(1))
                    _RunnerUpRow(
                      entry: entry,
                      isMe: entry.employeeName == employeeName,
                    ),
                  // Rows stay built while sliding closed, then leave the tree.
                  if (canExpand && !_reveal.isDismissed)
                    SizeTransition(
                      sizeFactor: _revealCurve,
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final entry in rest)
                            _RunnerUpRow(
                              entry: entry,
                              isMe: entry.employeeName == employeeName,
                            ),
                        ],
                      ),
                    ),
                  _ShowTotalFooter(
                    total: showTotal,
                    expanded: expanded,
                    onToggle: canExpand ? _toggle : null,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.entry, required this.isMe});

  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
      child: Row(
        children: [
          SizedBox(
            width: _rankColumnWidth,
            child: _Ordinal(rank: entry.rank, size: 44, color: AppColors.navy),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LEADING THE SHOW',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.greenText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.employeeName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                // No room beside the leader's large name, so the badge
                // goes underneath.
                if (isMe) ...[const SizedBox(height: 6), const _YouBadge()],
              ],
            ),
          ),
          SizedBox(
            width: _countColumnWidth,
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${entry.leadCount}',
                    style: const TextStyle(
                      color: AppColors.greenText,
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Text(
                  entry.leadCount == 1 ? 'sign-up' : 'sign-ups',
                  style: const TextStyle(
                    color: AppColors.greenText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RunnerUpRow extends StatelessWidget {
  const _RunnerUpRow({required this.entry, required this.isMe});

  final LeaderboardEntry entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isMe ? AppColors.greenTint : const Color(0xFFF6F7F6),
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
      child: Row(
        children: [
          SizedBox(
            width: _rankColumnWidth,
            child: _Ordinal(
              rank: entry.rank,
              size: 26,
              color: const Color(0xFFA3A8B0),
            ),
          ),
          Expanded(
            child: _NameWithBadge(
              name: entry.employeeName,
              isMe: isMe,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: _countColumnWidth,
            child: Text(
              '${entry.leadCount}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Navy bar with every team member's combined leads. [onToggle] is null when
/// there is nobody beyond the top three to reveal.
class _ShowTotalFooter extends StatelessWidget {
  const _ShowTotalFooter({
    required this.total,
    required this.expanded,
    required this.onToggle,
  });

  final int total;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    const subtle = TextStyle(color: Color(0xB3FFFFFF), fontSize: 13);
    return ColoredBox(
      color: AppColors.navyCard,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SHOW TOTAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'All team members',
                          overflow: TextOverflow.ellipsis,
                          style: subtle,
                        ),
                      ),
                      if (onToggle != null) ...[
                        const Text('  ·  ', style: subtle),
                        _ToggleLink(expanded: expanded, onTap: onToggle!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: _countColumnWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$total',
                  style: const TextStyle(
                    color: AppColors.brightGreen,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleLink extends StatelessWidget {
  const _ToggleLink({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                expanded ? 'Show less' : 'Show all',
                style: const TextStyle(
                  color: AppColors.brightGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 280),
                child: const Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: AppColors.brightGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameWithBadge extends StatelessWidget {
  const _NameWithBadge({
    required this.name,
    required this.isMe,
    required this.style,
  });

  final String name;
  final bool isMe;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(name, overflow: TextOverflow.ellipsis, style: style),
        ),
        if (isMe) ...[const SizedBox(width: 8), const _YouBadge()],
      ],
    );
  }
}

class _YouBadge extends StatelessWidget {
  const _YouBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'YOU',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// "1st", "2nd", "3rd", "12th" in a softened solid color.
class _Ordinal extends StatelessWidget {
  const _Ordinal({required this.rank, required this.size, required this.color});

  final int rank;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final faded = color.withValues(alpha: 0.7);
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: _rankSlotWidth,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$rank',
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w700,
                  color: faded,
                  height: 1,
                ),
              ),
              TextSpan(
                text: ordinalSuffix(rank),
                style: TextStyle(
                  fontSize: size * 0.5,
                  fontWeight: FontWeight.w700,
                  color: faded,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          semanticsLabel: 'Rank $rank',
        ),
      ),
    );
  }
}
