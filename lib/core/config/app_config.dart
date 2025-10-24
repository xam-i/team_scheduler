enum Environment { development, production }

class AppConfig {
  static const Environment _environment = Environment.production;

  // Supabase Configuration
  static const String supabaseUrl = 'https://wjcdutzlamxihrgkxkad.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndqY2R1dHpsYW14aWhyZ2t4a2FkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MjM2MzUsImV4cCI6MjA3MzQ5OTYzNX0.GRj0ikI2hnF_ISO1af_q8GTGaG4DgWCvB7_JiHErZ3Y';
  static const String storageBucket = 'profile';

  // App Configuration
  static const String appName = 'Team Scheduler';
  static const String appVersion = '1.0.0';

  // Feature Flags
  static const bool enableLocalStorageFallback = true;
  static const bool enableDemoData = true;
  static const bool enableErrorLogging = true;

  // Validation Rules
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minTaskTitleLength = 3;
  static const int maxTaskTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int minAvailabilityDurationMinutes = 15;

  // UI Configuration
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration errorSnackBarDuration = Duration(seconds: 4);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  // Colors
  static const int primaryColorValue = 0xFF8B5CF6;
  static const int secondaryColorValue = 0xFFA78BFA;
  static const int tertiaryColorValue = 0xFFC4B5FD;

  // Getters
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isProduction => _environment == Environment.production;

  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.production:
        return 'Production';
    }
  }
}
