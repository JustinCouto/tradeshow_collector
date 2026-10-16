import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../models/lead.dart';
import '../ordinal.dart';
import '../theme.dart';
import '../widgets/app_header.dart';
import '../widgets/primary_button.dart';
import '../widgets/saved_lead_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/top_performers_card.dart';
import 'add_lead_screen.dart';
import 'add_notes_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key, required this.employeeName});

  final String employeeName;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  EmployeeStats? _stats;
  List<LeaderboardEntry>? _leaderboard;
  bool _loadFailed = false;

  bool _started = false;

  /// Set only when this screen was reached by saving a lead.
  NewLead? _justSaved;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _load();
    }
  }

  Future<void> _load() async {
    final services = AppServices.of(context);
    if (_loadFailed) setState(() => _loadFailed = false);
    try {
      final results = await Future.wait([
        services.repository.fetchStats(
          widget.employeeName,
          now: services.clock(),
        ),
        services.repository.fetchLeaderboard(),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as EmployeeStats;
        _leaderboard = results[1] as List<LeaderboardEntry>;
      });
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  Future<void> _openNewLead() async {
    setState(() => _justSaved = null);
    final saved = await Navigator.of(context).push<NewLead>(
      MaterialPageRoute(
        builder: (_) => AddLeadScreen(employeeName: widget.employeeName),
      ),
    );
    if (saved == null || !mounted) return;
    setState(() => _justSaved = saved);
    await _load();
  }

  Future<void> _openNotes() async {
    final lead = _justSaved;
    if (lead == null) return;
    final updated = await Navigator.of(context).push<NewLead>(
      MaterialPageRoute(
        builder: (_) =>
            AddNotesScreen(employeeName: widget.employeeName, lead: lead),
      ),
    );
    if (updated == null || !mounted) return;
    setState(() => _justSaved = updated);
  }

  @override
  Widget build(BuildContext context) {
    final today = AppServices.of(context).clock();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppHeader(employeeName: widget.employeeName),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.green,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Expanded(
                        child: Text(
                          'Overview',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),
                      Text(
                        '${DateFormat('EEE, MMM d').format(today)}'
                        '${ordinalSuffix(today.day)}',
                        style: const TextStyle(
                          color: AppColors.body,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_justSaved != null) ...[
                    SavedLeadCard(lead: _justSaved!, onEditNotes: _openNotes),
                    const SizedBox(height: 18),
                  ],
                  if (_loadFailed) ...[
                    _LoadErrorBanner(onRetry: _load),
                    const SizedBox(height: 18),
                  ],
                  StatsCard(stats: _stats),
                  if (!_loadFailed || _leaderboard != null) ...[
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TopPerformersCard(
                      entries: _leaderboard,
                      employeeName: widget.employeeName,
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(22, 8, 22, 16),
            child: PrimaryButton(label: 'New Sign-up', onPressed: _openNewLead),
          ),
        ],
      ),
    );
  }
}

class _LoadErrorBanner extends StatelessWidget {
  const _LoadErrorBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.errorFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Couldn't load totals. Check the connection.",
              style: TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
