import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lead.dart';

abstract interface class LeadsRepository {
  Future<void> addLead(NewLead lead, {required String employeeName});

  /// [now] decides which local calendar day counts as "today".
  Future<EmployeeStats> fetchStats(
    String employeeName, {
    required DateTime now,
  });

  /// Every employee with at least one lead, highest total first.
  Future<List<LeaderboardEntry>> fetchLeaderboard();

  /// Names of everyone who has saved a lead, for sign-in suggestions.
  Future<List<String>> fetchEmployeeNames();
}

class SupabaseLeadsRepository implements LeadsRepository {
  SupabaseLeadsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> addLead(NewLead lead, {required String employeeName}) async {
    // No .select() afterwards: the anon role can insert but not read rows back.
    await _client.from('customer_leads').insert({
      'first_name': lead.firstName,
      'last_name': lead.lastName,
      'company_name': lead.companyName,
      'email_address': lead.emailAddress,
      'employee_name': employeeName,
    });
  }

  @override
  Future<EmployeeStats> fetchStats(
    String employeeName, {
    required DateTime now,
  }) async {
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = DateTime(now.year, now.month, now.day + 1);
    final rows = await _client.rpc<List<dynamic>>(
      'employee_stats',
      params: {
        'p_employee_name': employeeName,
        'p_day_start': dayStart.toUtc().toIso8601String(),
        'p_day_end': dayEnd.toUtc().toIso8601String(),
      },
    );
    if (rows.isEmpty) {
      return const EmployeeStats(leadsToday: 0, showTotal: 0);
    }
    final row = rows.first as Map<String, dynamic>;
    return EmployeeStats(
      leadsToday: (row['today_count'] as num).toInt(),
      showTotal: (row['show_total'] as num).toInt(),
    );
  }

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final rows = await _client.rpc<List<dynamic>>('leaderboard');
    return [
      for (final row in rows.cast<Map<String, dynamic>>())
        LeaderboardEntry(
          rank: (row['employee_rank'] as num).toInt(),
          employeeName: row['employee_name'] as String,
          leadCount: (row['lead_count'] as num).toInt(),
        ),
    ];
  }

  @override
  Future<List<String>> fetchEmployeeNames() async => [
    for (final entry in await fetchLeaderboard()) entry.employeeName,
  ];
}

/// Sample data for `DEMO_MODE` runs and tests. Nothing leaves the device.
class InMemoryLeadsRepository implements LeadsRepository {
  InMemoryLeadsRepository({Map<String, int>? priorShowTotals})
    : _priorTotals = {...?priorShowTotals};

  factory InMemoryLeadsRepository.sample() => InMemoryLeadsRepository(
    priorShowTotals: {'David Chen': 38, 'Priya Shah': 34, 'Sam Ortiz': 12},
  );

  final Map<String, int> _priorTotals;
  final List<({String employeeName, DateTime created})> _added = [];

  @override
  Future<void> addLead(NewLead lead, {required String employeeName}) async {
    _added.add((employeeName: employeeName, created: DateTime.now()));
  }

  @override
  Future<EmployeeStats> fetchStats(
    String employeeName, {
    required DateTime now,
  }) async {
    final mine = _added.where((l) => l.employeeName == employeeName);
    final today = mine.where(
      (l) =>
          l.created.year == now.year &&
          l.created.month == now.month &&
          l.created.day == now.day,
    );
    return EmployeeStats(
      leadsToday: today.length,
      showTotal: (_priorTotals[employeeName] ?? 0) + mine.length,
    );
  }

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final totals = {..._priorTotals};
    for (final lead in _added) {
      totals.update(lead.employeeName, (n) => n + 1, ifAbsent: () => 1);
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    final entries = <LeaderboardEntry>[];
    for (var i = 0; i < sorted.length; i++) {
      final sameAsPrevious = i > 0 && sorted[i].value == sorted[i - 1].value;
      entries.add(
        LeaderboardEntry(
          rank: sameAsPrevious ? entries[i - 1].rank : i + 1,
          employeeName: sorted[i].key,
          leadCount: sorted[i].value,
        ),
      );
    }
    return entries;
  }

  @override
  Future<List<String>> fetchEmployeeNames() async => {
    ..._priorTotals.keys,
    for (final lead in _added) lead.employeeName,
  }.toList();
}
