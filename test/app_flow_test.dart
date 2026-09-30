import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradeshow_collector/app.dart';
import 'package:tradeshow_collector/services/leads_repository.dart';
import 'package:tradeshow_collector/services/session_store.dart';

void main() {
  final now = DateTime(2026, 9, 29, 10);

  Future<SessionStore> pumpApp(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    InMemoryLeadsRepository? repository,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    final session = await SessionStore.load();
    await tester.pumpWidget(
      LeadCaptureApp(
        session: session,
        repository: repository ?? InMemoryLeadsRepository.sample(),
        clock: () => now,
      ),
    );
    await tester.pumpAndSettle();
    return session;
  }

  FilledButton button(WidgetTester tester, String label) => tester.widget(
    find.ancestor(of: find.text(label), matching: find.byType(FilledButton)),
  );

  Finder field(String label) => find.descendant(
    of: find
        .ancestor(of: find.textContaining(label), matching: find.byType(Column))
        .first,
    matching: find.byType(TextField),
  );

  testWidgets('sign in, add a lead, see it on the overview, sign out', (
    tester,
  ) async {
    final session = await pumpApp(tester);

    expect(find.text('Tradeshow Lead Capture'), findsOneWidget);
    expect(button(tester, 'Continue').onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  Maria  Lopez ');
    await tester.pump();
    expect(button(tester, 'Continue').onPressed, isNotNull);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(session.employeeName, 'Maria Lopez');
    expect(find.text('Welcome, Maria'), findsOneWidget);
    expect(find.text('Signed in as'), findsOneWidget);
    expect(find.text('TUESDAY, SEP 29'), findsOneWidget);
    expect(find.text('Lead saved'), findsNothing);
    expect(find.text('David Chen'), findsOneWidget);

    await tester.tap(find.text('New Lead'));
    await tester.pumpAndSettle();
    expect(button(tester, 'Save Lead').onPressed, isNull);

    await tester.enterText(field('First name'), 'Jordan');
    await tester.enterText(field('Last name'), 'Reyes');
    await tester.enterText(field('Company'), 'Northwind Studios');
    await tester.enterText(field('Email address'), 'jordan@northwind');
    await tester.pump();
    expect(button(tester, 'Save Lead').onPressed, isNull);

    await tester.tap(field('First name'));
    await tester.pump();
    expect(
      find.text('Enter a valid email, like name@company.com'),
      findsOneWidget,
    );

    await tester.enterText(field('Email address'), 'jordan@northwind.io');
    await tester.pump();
    expect(
      find.text('Enter a valid email, like name@company.com'),
      findsNothing,
    );
    expect(button(tester, 'Save Lead').onPressed, isNotNull);

    await tester.tap(find.text('Save Lead'));
    await tester.pumpAndSettle();

    expect(find.text('Nice work, Maria!'), findsOneWidget);
    expect(find.text('Lead saved'), findsOneWidget);
    expect(find.text('Jordan Reyes'), findsOneWidget);
    expect(find.text('JR'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('YOU'), findsOneWidget);

    await tester.tap(find.text('New Lead'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Maria'), findsOneWidget);
    expect(find.text('Lead saved'), findsNothing);

    await tester.tap(find.text('Maria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Tradeshow Lead Capture'), findsOneWidget);
    expect(session.employeeName, isNull);
  });

  testWidgets('typing a few letters suggests existing employees', (
    tester,
  ) async {
    final session = await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'pri');
    await tester.pumpAndSettle();
    expect(find.text('Priya Shah', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Priya Shah', findRichText: true));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Priya Shah',
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(session.employeeName, 'Priya Shah');
    expect(find.text('Welcome, Priya'), findsOneWidget);
  });

  testWidgets('a differently capitalized name uses the existing spelling', (
    tester,
  ) async {
    final session = await pumpApp(tester);
    await tester.enterText(find.byType(TextField), 'david chen');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(session.employeeName, 'David Chen');
  });

  testWidgets('a remembered name skips sign in', (tester) async {
    await pumpApp(tester, prefs: {'employee_name': 'Priya Shah'});
    expect(find.text('Welcome, Priya'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('34'), findsWidgets);
  });

  testWidgets('sign out from the form returns to sign in', (tester) async {
    await pumpApp(tester, prefs: {'employee_name': 'Sam Ortiz'});
    // Rank 4 shows under the top three.
    expect(find.text('Sam Ortiz'), findsOneWidget);
    await tester.tap(find.text('New Lead'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Tradeshow Lead Capture'), findsOneWidget);
  });
}
