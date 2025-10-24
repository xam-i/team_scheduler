import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/supabase_config.dart';
import 'core/repositories/user_repository.dart';
import 'core/repositories/availability_repository.dart';
import 'core/repositories/task_repository.dart';
import 'core/bloc/user_cubit.dart';
import 'core/bloc/availability_cubit.dart';
import 'core/bloc/task_cubit.dart';
import 'core/storage/local_storage.dart';
import 'presentation/pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize demo data
  AppLocalStorage().initializeDemoData();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              UserCubit(userRepository: UserRepository())..loadCurrentUser(),
        ),
        BlocProvider(
          create: (context) => AvailabilityCubit(
            availabilityRepository: AvailabilityRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => TaskCubit(taskRepository: TaskRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Team Scheduler',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B5CF6), // Light purple
            brightness: Brightness.light,
            primary: const Color(0xFF8B5CF6),
            secondary: const Color(0xFFA78BFA),
            tertiary: const Color(0xFFC4B5FD),
            surface: const Color(0xFFF8FAFC),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
        home: const OnboardingPage(),
      ),
    );
  }
}
