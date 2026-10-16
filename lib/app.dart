import 'package:flutter/material.dart';

import 'screens/overview_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/leads_repository.dart';
import 'services/session_store.dart';
import 'theme.dart';

class LeadCaptureApp extends StatelessWidget {
  const LeadCaptureApp({
    super.key,
    required this.session,
    required this.repository,
    this.clock = DateTime.now,
  });

  final SessionStore session;
  final LeadsRepository repository;
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    return AppServices(
      session: session,
      repository: repository,
      clock: clock,
      child: MaterialApp(
        title: 'SoCreate Sign-ups',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: ListenableBuilder(
          listenable: session,
          builder: (context, _) {
            final name = session.employeeName;
            return name == null
                ? const SignInScreen()
                : OverviewScreen(key: ValueKey(name), employeeName: name);
          },
        ),
      ),
    );
  }
}

/// Gives every screen access to the session, the data source and the clock.
class AppServices extends InheritedWidget {
  const AppServices({
    super.key,
    required this.session,
    required this.repository,
    required this.clock,
    required super.child,
  });

  final SessionStore session;
  final LeadsRepository repository;
  final DateTime Function() clock;

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppServices>()!;

  /// Drops any open screens and returns to sign-in.
  Future<void> signOut(BuildContext context) async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    await session.signOut();
  }

  @override
  bool updateShouldNotify(AppServices oldWidget) =>
      session != oldWidget.session ||
      repository != oldWidget.repository ||
      clock != oldWidget.clock;
}
