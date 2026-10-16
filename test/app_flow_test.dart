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
    // The sign-in circles drift forever unless motion is reduced, which
    // would keep pumpAndSettle from ever settling.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
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

  Future<void> tapLink(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('sign in, add a lead, see it on the overview, sign out', (
    tester,
  ) async {
    final session = await pumpApp(tester);

    expect(find.text('Sign-up Capture'), findsOneWidget);
    expect(find.text('Team Member'), findsOneWidget);
    expect(button(tester, 'Continue').onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  Maria  Lopez ');
    await tester.pump();
    expect(button(tester, 'Continue').onPressed, isNotNull);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(session.employeeName, 'Maria Lopez');
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Leaderboard'), findsOneWidget);
    expect(find.text('Signed in as'), findsOneWidget);
    expect(find.text('Tue, Sep 29th'), findsOneWidget);
    expect(find.text('Sign-up saved'), findsNothing);
    expect(find.text('David Chen'), findsOneWidget);
    // 38 + 34 + 12 across the sample team.
    expect(find.text('84'), findsOneWidget);

    await tester.tap(find.text('New Sign-up'));
    await tester.pumpAndSettle();
    expect(find.text('Notify on Launch'), findsOneWidget);
    expect(button(tester, 'Save Sign-up').onPressed, isNull);

    await tester.enterText(field('First name'), 'Jordan');
    await tester.enterText(field('Last name'), 'Reyes');
    await tester.enterText(field('Company'), 'Northwind Studios');
    await tester.enterText(field('Email address'), 'jordan@northwind');
    await tester.pump();
    expect(button(tester, 'Save Sign-up').onPressed, isNull);

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
    expect(button(tester, 'Save Sign-up').onPressed, isNotNull);

    await tester.tap(find.text('Save Sign-up'));
    await tester.pumpAndSettle();

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Sign-up saved'), findsOneWidget);
    expect(find.text('Jordan Reyes'), findsOneWidget);
    expect(find.text('JR'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
    expect(find.text('85'), findsOneWidget);
    // Maria is 4th, so her row waits behind Show all.
    expect(find.text('YOU'), findsNothing);
    await tapLink(tester, 'Show all');
    expect(find.text('YOU'), findsOneWidget);

    await tester.tap(find.text('New Sign-up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Sign-up saved'), findsNothing);

    await tester.tap(find.text('Maria'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign-up Capture'), findsOneWidget);
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
    expect(find.text('Overview'), findsOneWidget);
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
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('34'), findsWidgets);
  });

  testWidgets('three or fewer team members hide the Show all link', (
    tester,
  ) async {
    await pumpApp(tester, prefs: {'employee_name': 'Priya Shah'});
    expect(find.text('Sam Ortiz'), findsOneWidget);
    expect(find.text('Show all'), findsNothing);
    expect(find.text('Show less'), findsNothing);
  });

  testWidgets('Show all reveals everyone and Show less collapses', (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefs: {'employee_name': 'Ann Avery'},
      repository: InMemoryLeadsRepository(
        priorShowTotals: {
          'Ann Avery': 10,
          'Ben Brooks': 9,
          'Cal Cruz': 8,
          'Dee Diaz': 7,
          'Eve Ellis': 6,
        },
      ),
    );
    expect(find.text('40'), findsOneWidget);
    expect(find.text('Cal Cruz'), findsOneWidget);
    expect(find.text('Dee Diaz'), findsNothing);
    expect(find.text('Eve Ellis'), findsNothing);

    await tapLink(tester, 'Show all');
    expect(find.text('Dee Diaz'), findsOneWidget);
    expect(find.text('Eve Ellis'), findsOneWidget);
    expect(find.text('Show all'), findsNothing);

    await tapLink(tester, 'Show less');
    expect(find.text('Dee Diaz'), findsNothing);
    expect(find.text('Eve Ellis'), findsNothing);
    expect(find.text('Show all'), findsOneWidget);
  });

  testWidgets('collapsed, even the signed-in member below 3rd is hidden', (
    tester,
  ) async {
    await pumpApp(
      tester,
      prefs: {'employee_name': 'Eve Ellis'},
      repository: InMemoryLeadsRepository(
        priorShowTotals: {
          'Ann Avery': 10,
          'Ben Brooks': 9,
          'Cal Cruz': 8,
          'Dee Diaz': 7,
          'Eve Ellis': 6,
        },
      ),
    );
    expect(find.text('Eve Ellis'), findsNothing);
    expect(find.text('Dee Diaz'), findsNothing);

    await tapLink(tester, 'Show all');
    expect(find.text('Eve Ellis'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
  });

  testWidgets('sign out from the form returns to sign in', (tester) async {
    await pumpApp(tester, prefs: {'employee_name': 'Sam Ortiz'});
    expect(find.text('Sam Ortiz'), findsOneWidget);
    await tester.tap(find.text('New Sign-up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign-up Capture'), findsOneWidget);
  });

  group('conversation notes', () {
    const longNotes =
        'Runs a 6-person writing team at Northwind. Interested in '
        'collaborative screenwriting for their animated series pilot.';

    Future<void> saveSignUp(WidgetTester tester) async {
      await tester.tap(find.text('New Sign-up'));
      await tester.pumpAndSettle();
      await tester.enterText(field('First name'), 'Jordan');
      await tester.enterText(field('Last name'), 'Reyes');
      await tester.enterText(field('Email address'), 'jordan@northwind.io');
      await tester.pump();
      await tester.tap(find.text('Save Sign-up'));
      await tester.pumpAndSettle();
    }

    Future<void> writeNotes(WidgetTester tester, String notes) async {
      await tester.enterText(find.byType(TextField), notes);
      await tester.pump();
      await tester.tap(find.text('Save Notes'));
      await tester.pumpAndSettle();
    }

    testWidgets('add, expand, collapse and edit notes', (tester) async {
      final repository = InMemoryLeadsRepository.sample();
      await pumpApp(
        tester,
        prefs: {'employee_name': 'Maria Lopez'},
        repository: repository,
      );
      await saveSignUp(tester);
      expect(find.text('Sign-up saved'), findsOneWidget);
      expect(find.text('CONVERSATION NOTES'), findsNothing);

      await tapLink(tester, 'Add Conversation Notes');
      expect(find.text('Add Notes'), findsOneWidget);
      expect(find.text('jordan@northwind.io'), findsOneWidget);
      expect(button(tester, 'Save Notes').onPressed, isNull);

      await writeNotes(tester, '  $longNotes  ');
      expect(find.text('Add Notes'), findsNothing);
      expect(find.text('Sign-up saved'), findsOneWidget);
      expect(repository.notes.values.single, longNotes);
      expect(find.text('CONVERSATION NOTES'), findsOneWidget);
      expect(find.text(longNotes), findsOneWidget);
      expect(find.text('Add Conversation Notes'), findsNothing);
      expect(find.byTooltip('Edit notes'), findsNothing);

      await tapLink(tester, 'Show more');
      expect(find.text('Show less'), findsOneWidget);
      expect(find.byTooltip('Edit notes'), findsOneWidget);

      await tapLink(tester, 'Show less');
      expect(find.text('Show more'), findsOneWidget);
      expect(find.byTooltip('Edit notes'), findsNothing);

      await tapLink(tester, 'Show more');
      await tester.tap(find.byTooltip('Edit notes'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Notes'), findsOneWidget);
      expect(find.text(longNotes), findsOneWidget);

      await writeNotes(tester, '$longNotes Follow up Oct 19.');
      expect(repository.notes.values.single, '$longNotes Follow up Oct 19.');
      expect(find.text('$longNotes Follow up Oct 19.'), findsOneWidget);
    });

    testWidgets('cancel leaves the notes unchanged', (tester) async {
      final repository = InMemoryLeadsRepository.sample();
      await pumpApp(
        tester,
        prefs: {'employee_name': 'Maria Lopez'},
        repository: repository,
      );
      await saveSignUp(tester);

      await tapLink(tester, 'Add Conversation Notes');
      await tester.enterText(find.byType(TextField), 'Never saved');
      await tester.pump();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.notes, isEmpty);
      expect(find.text('Add Conversation Notes'), findsOneWidget);
      expect(find.text('Never saved'), findsNothing);
    });

    testWidgets('short notes show in full without Show more', (tester) async {
      await pumpApp(tester, prefs: {'employee_name': 'Maria Lopez'});
      await saveSignUp(tester);

      await tapLink(tester, 'Add Conversation Notes');
      await writeNotes(tester, 'Demo');
      expect(find.text('Demo'), findsOneWidget);
      expect(find.text('Show more'), findsNothing);
      expect(find.byTooltip('Edit notes'), findsOneWidget);
    });
  });
}
