/// Build-time settings passed with `--dart-define-from-file=dart_defines.json`.
///
/// Only the anon (publishable) key belongs here. The service role key bypasses
/// row level security and must never be compiled into the app.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Runs the app against in-memory sample data instead of Supabase.
  static const demoMode = bool.fromEnvironment('DEMO_MODE');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
