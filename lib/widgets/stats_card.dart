import 'package:flutter/material.dart';

import '../models/lead.dart';
import '../theme.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key, required this.stats});

  /// Null while loading; the numbers show a dash.
  final EmployeeStats? stats;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ColoredBox(
        color: AppColors.navyCard,
        child: Stack(
          children: [
            const Positioned(
              right: -70,
              top: -40,
              child: _Circle(size: 210, color: Color(0xFF2A4432)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        label: "Today's Sign-ups",
                        value: stats?.leadsToday,
                        color: AppColors.brightGreen,
                      ),
                    ),
                    const VerticalDivider(
                      width: 30,
                      thickness: 1,
                      color: Color(0x33FFFFFF),
                    ),
                    Expanded(
                      child: _Stat(
                        label: 'Your Show Total',
                        value: stats?.showTotal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final int? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xDDFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value?.toString() ?? '–',
          style: TextStyle(
            color: color,
            fontSize: 52,
            fontWeight: FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.5,
          ),
        ),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
