class NewLead {
  NewLead({
    required String firstName,
    required String lastName,
    String? companyName,
    required String emailAddress,
  }) : firstName = firstName.trim(),
       lastName = lastName.trim(),
       companyName = _blankToNull(companyName),
       emailAddress = emailAddress.trim().toLowerCase();

  final String firstName;
  final String lastName;
  final String? companyName;
  final String emailAddress;

  String get fullName => '$firstName $lastName';

  String get initials =>
      '${_firstLetter(firstName)}${_firstLetter(lastName)}'.toUpperCase();

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static String _firstLetter(String value) =>
      value.isEmpty ? '' : String.fromCharCode(value.runes.first);
}

class EmployeeStats {
  const EmployeeStats({required this.leadsToday, required this.showTotal});

  final int leadsToday;
  final int showTotal;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.employeeName,
    required this.leadCount,
  });

  final int rank;
  final String employeeName;
  final int leadCount;
}
