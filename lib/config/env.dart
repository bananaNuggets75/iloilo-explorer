import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App environment / secrets, loaded from `.env.local` (git-ignored).
///
/// Loading is best-effort: if the file or keys are missing, [isConfigured] is
/// false and the app runs entirely on bundled seed data. This keeps the app
/// working with zero setup and lets Supabase "light up" once keys are added.
class Env {
  static bool _loaded = false;

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env.local');
    } catch (_) {
      // No env file bundled — fine, we fall back to seed data.
    }
    _loaded = true;
  }

  static String get supabaseUrl =>
      _get('NEXT_PUBLIC_SUPABASE_URL');

  static String get supabaseKey =>
      _get('NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY');

  /// True only when both Supabase values are present.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  static String _get(String key) {
    if (!_loaded) return '';
    try {
      return dotenv.env[key] ?? '';
    } catch (_) {
      return '';
    }
  }
}
