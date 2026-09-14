# Hala2026

Hala2026 is a simple, local-first expense tracker for people in Quebec. It records everyday spending in Canadian dollars (CAD); it does not provide tax, accounting, or financial advice.

## Current features

- Add an expense with an amount, category, date, and optional note.
- See the current month's total spending and category totals.
- Review recent expenses and remove one with a left swipe.
- Save entries only on the current device.

## Run locally

1. Install Flutter and Android Studio, then start an Android emulator or connect an Android phone with USB debugging enabled.
2. On Windows, enable **Settings > System > For developers > Developer Mode**. Flutter plugins need this to create symbolic links.
3. From the project folder, run:

   ```powershell
   flutter pub get
   flutter run
   ```

## Quality checks

Run the following before committing changes:

```powershell
flutter analyze
flutter test
```

## Important release work still required

Before publishing to Google Play, choose a unique Android application ID, configure a protected release signing key, add a privacy policy and data/backup decisions, and establish automated CI checks.
