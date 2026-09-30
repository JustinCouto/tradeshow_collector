final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[A-Za-z]{2,}$');

bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

bool canSaveLead({
  required String firstName,
  required String lastName,
  required String emailAddress,
}) =>
    firstName.trim().isNotEmpty &&
    lastName.trim().isNotEmpty &&
    isValidEmail(emailAddress);

/// "Maria Lopez" -> "Maria", used in the header and greeting.
String firstNameOf(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  return parts.first;
}
