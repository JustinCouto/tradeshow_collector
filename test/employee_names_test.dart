import 'package:flutter_test/flutter_test.dart';
import 'package:tradeshow_collector/employee_names.dart';

void main() {
  const names = ['Maria Lopez', 'Mark Chen', 'David Chen', 'Priya Shah'];

  group('matchEmployeeNames', () {
    test('matches the start of the full name, ignoring case', () {
      expect(matchEmployeeNames(names, 'mar'), ['Maria Lopez', 'Mark Chen']);
      expect(matchEmployeeNames(names, 'MARIA'), ['Maria Lopez']);
    });

    test('matches the start of a last name after full-name matches', () {
      expect(matchEmployeeNames(names, 'che'), ['David Chen', 'Mark Chen']);
      expect(matchEmployeeNames(names, 'lo'), ['Maria Lopez']);
    });

    test('does not match letters in the middle of a word', () {
      expect(matchEmployeeNames(names, 'ria'), isEmpty);
    });

    test('suggests nothing for blank input or an exact match', () {
      expect(matchEmployeeNames(names, '  '), isEmpty);
      expect(matchEmployeeNames(names, 'maria  lopez'), isEmpty);
    });
  });

  group('canonicalEmployeeName', () {
    test('uses the existing spelling for a case or spacing difference', () {
      expect(canonicalEmployeeName(names, ' maria   LOPEZ '), 'Maria Lopez');
    });

    test('keeps a new name as typed', () {
      expect(canonicalEmployeeName(names, 'Sam Ortiz'), 'Sam Ortiz');
    });
  });
}
