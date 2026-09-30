String _normalize(String name) =>
    name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

/// Names worth suggesting for [query]: any name where the full name or one of
/// its words starts with what was typed. Full-name matches come first.
List<String> matchEmployeeNames(Iterable<String> names, String query) {
  final q = _normalize(query);
  if (q.isEmpty) return const [];

  final byFullName = <String>[];
  final byWord = <String>[];
  for (final name in names) {
    final n = _normalize(name);
    if (n == q) continue;
    if (n.startsWith(q)) {
      byFullName.add(name);
    } else if (n.split(' ').any((word) => word.startsWith(q))) {
      byWord.add(name);
    }
  }
  int alpha(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());
  return [...byFullName..sort(alpha), ...byWord..sort(alpha)];
}

/// The existing spelling of [typed] if someone already signed in under that
/// name with different capitalization or spacing, otherwise [typed] itself.
String canonicalEmployeeName(Iterable<String> names, String typed) {
  final t = _normalize(typed);
  for (final name in names) {
    if (_normalize(name) == t) return name;
  }
  return typed;
}
