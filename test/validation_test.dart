import 'package:flutter_test/flutter_test.dart';
import 'package:tradeshow_collector/models/lead.dart';
import 'package:tradeshow_collector/validation.dart';

void main() {
  group('isValidEmail', () {
    test('accepts normal addresses', () {
      expect(isValidEmail('jordan@northwind.io'), isTrue);
      expect(isValidEmail('first.last+show@sub.company.com'), isTrue);
      expect(isValidEmail('  maria@socreate.it  '), isTrue);
    });

    test('rejects incomplete or malformed addresses', () {
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail('jordan'), isFalse);
      expect(isValidEmail('jordan@northwind'), isFalse);
      expect(isValidEmail('jordan@northwind.'), isFalse);
      expect(isValidEmail('jordan@northwind.c'), isFalse);
      expect(isValidEmail('@northwind.io'), isFalse);
      expect(isValidEmail('jordan@@northwind.io'), isFalse);
      expect(isValidEmail('jor dan@northwind.io'), isFalse);
    });
  });

  group('canSaveLead', () {
    test('needs first name, last name and a valid email', () {
      expect(
        canSaveLead(
          firstName: 'Jordan',
          lastName: 'Reyes',
          emailAddress: 'jordan@northwind.io',
        ),
        isTrue,
      );
    });

    test('blocks when any required field is blank or the email is invalid', () {
      expect(
        canSaveLead(firstName: ' ', lastName: 'Reyes', emailAddress: 'a@b.co'),
        isFalse,
      );
      expect(
        canSaveLead(firstName: 'Jordan', lastName: '', emailAddress: 'a@b.co'),
        isFalse,
      );
      expect(
        canSaveLead(
          firstName: 'Jordan',
          lastName: 'Reyes',
          emailAddress: 'jordan@northwind',
        ),
        isFalse,
      );
    });
  });

  test('firstNameOf takes the first word', () {
    expect(firstNameOf('Maria Lopez'), 'Maria');
    expect(firstNameOf('  Priya   Shah '), 'Priya');
    expect(firstNameOf('Cher'), 'Cher');
  });

  test('NewLead trims, blanks an empty company, and lowercases email', () {
    final lead = NewLead(
      firstName: ' jordan ',
      lastName: 'Reyes ',
      companyName: '   ',
      emailAddress: ' Jordan@Northwind.IO ',
    );
    expect(lead.fullName, 'jordan Reyes');
    expect(lead.companyName, isNull);
    expect(lead.emailAddress, 'jordan@northwind.io');
    expect(lead.initials, 'JR');
  });

  test('NewLead gets a fresh v4 id that survives adding notes', () {
    NewLead make() =>
        NewLead(firstName: 'A', lastName: 'B', emailAddress: 'a@b.co');
    final lead = make();
    expect(
      lead.leadId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-'
          r'[0-9a-f]{12}$',
        ),
      ),
    );
    expect(make().leadId, isNot(lead.leadId));

    final withNotes = lead.withNotes('  Call back  ');
    expect(withNotes.leadId, lead.leadId);
    expect(withNotes.notes, 'Call back');
    expect(withNotes.withNotes('   ').notes, isNull);
  });
}
