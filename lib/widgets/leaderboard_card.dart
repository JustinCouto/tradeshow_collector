import 'package:flutter/material.dart';

import '../models/lead.dart';
import '../theme.dart';

/// Shared by every row so the lead counts line up in one column.
const _countColumnWidth = 60.0;

/// Top three employees, plus the signed-in employee's row when they are
/// further down.
class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({
    super.key,
    required this.entries,
    required this.employeeName,
  });

  /// Null while loading.
  final List<LeaderboardEntry>? entries;
  final String employeeName;

  @override
  Widget build(BuildContext context) {
    final all = entries;
    final top = all?.take(3).toList() ?? const <LeaderboardEntry>[];
    final me = all?.where((e) => e.employeeName == employeeName).firstOrNull;
    final showMeBelow = me != null && !top.contains(me);

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
                      'No leads yet. Be the first on the board!',
                      style: TextStyle(color: AppColors.body, fontSize: 15),
                    ),
                  )
                else ...[
                  _LeaderRow(
                    entry: top.first,
                    isMe: top.first.employeeName == employeeName,
                  ),
                  for (final entry in [...top.skip(1), if (showMeBelow) me])
                    _RunnerUpRow(
                      entry: entry,
                      isMe: entry.employeeName == employeeName,
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
            width: 84,
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
                  entry.leadCount == 1 ? 'lead' : 'leads',
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
            width: 84,
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

/// Outlined "1st", "2nd", "3rd", "12th" styled like the mockup.
class _Ordinal extends StatelessWidget {
  const _Ordinal({required this.rank, required this.size, required this.color});

  final int rank;
  final double size;
  final Color color;

  static String suffix(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return 'th';
    return switch (n % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }

  @override
  Widget build(BuildContext context) {
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size > 30 ? 1.4 : 1.1
      ..color = color;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$rank',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w400,
              foreground: outline,
              height: 1,
            ),
          ),
          TextSpan(
            text: suffix(rank),
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.w400,
              foreground: outline,
            ),
          ),
        ],
      ),
      semanticsLabel: 'Rank $rank',
    );
  }
}
