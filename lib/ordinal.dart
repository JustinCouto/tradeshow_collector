/// English ordinal suffix: 1 -> "st", 2 -> "nd", 3 -> "rd", 11 -> "th".
String ordinalSuffix(int n) {
  if (n % 100 >= 11 && n % 100 <= 13) return 'th';
  return switch (n % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}
