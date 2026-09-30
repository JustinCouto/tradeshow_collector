# SoCreate Tradeshow Lead Capture

Flutter app for collecting leads at tradeshows. Employees enter their name once,
then add leads (first name, last name, optional company, email). Leads are saved
to Supabase with the employee's name, and the overview shows today's count,
show total, and a leaderboard.

Android is the target today; the iOS project is included for later.

## 1. Set up Supabase (once)

1. In the Supabase dashboard open **SQL Editor > New query**.
2. Paste the contents of [`supabase/schema.sql`](supabase/schema.sql) and click **Run**.
3. Open **Project Settings > API** and copy the **Project URL** and the
   **anon / publishable** key. Never use the `service_role` / secret key in the app.

The schema turns on row level security so the app can only **add** leads. It
cannot read, edit, or delete rows; totals come from two functions that return
counts only. View and export leads from **Table Editor > customer_leads** in the
dashboard.

## 2. Add the keys

```sh
cp dart_defines.example.json dart_defines.json
```

Fill in `SUPABASE_URL` and `SUPABASE_ANON_KEY`. `dart_defines.json` is gitignored.

## 3. Run and build

```sh
flutter run --dart-define-from-file=dart_defines.json
flutter build apk --release --dart-define-from-file=dart_defines.json
```

The APK lands in `build/app/outputs/flutter-apk/app-release.apk`. Copy it to each
device and allow "Install unknown apps" for the file manager used to open it.

Building for Android needs the Android SDK and a JDK (installing Android Studio
provides both; then run `flutter doctor --android-licenses`).

To try the app without Supabase, use sample data:

```sh
flutter run -d chrome --dart-define=DEMO_MODE=true
```

## Tests

```sh
flutter test
```
