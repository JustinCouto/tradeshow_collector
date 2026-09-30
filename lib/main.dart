import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/supabase_config.dart';
import 'services/leads_repository.dart';
import 'services/session_store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final LeadsRepository repository;
  if (SupabaseConfig.demoMode) {
    repository = InMemoryLeadsRepository.sample();
  } else if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
    repository = SupabaseLeadsRepository(Supabase.instance.client);
  } else {
    runApp(const _MissingConfigApp());
    return;
  }

  final session = await SessionStore.load();
  runApp(LeadCaptureApp(session: session, repository: repository));
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'This build has no Supabase settings.\n\n'
              'Copy dart_defines.example.json to dart_defines.json, fill in the '
              'project URL and anon key, then build with\n'
              '--dart-define-from-file=dart_defines.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
