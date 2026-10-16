import 'dart:math';

class NewLead {
  NewLead({
    String? leadId,
    required String firstName,
    required String lastName,
    String? companyName,
    required String emailAddress,
    String? notes,
  }) : leadId = leadId ?? _randomUuid(),
       firstName = firstName.trim(),
       lastName = lastName.trim(),
       companyName = _blankToNull(companyName),
       emailAddress = emailAddress.trim().toLowerCase(),
       notes = _blankToNull(notes);

  /// Chosen on the phone so notes can be attached to the saved row later;
  /// the app isn't allowed to read rows back to learn the id.
  final String leadId;
  final String firstName;
  final String lastName;
  final String? companyName;
  final String emailAddress;
  final String? notes;

  String get fullName => '$firstName $lastName';

  NewLead withNotes(String? notes) => NewLead(
    leadId: leadId,
    firstName: firstName,
    lastName: lastName,
    companyName: companyName,
    emailAddress: emailAddress,
    notes: notes,
  );

  /// Version 4 UUID.
  static String _randomUuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

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
