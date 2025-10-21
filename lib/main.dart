import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/supabase_config.dart';
import 'core/repositories/user_repository.dart';
import 'core/repositories/availability_repository.dart';
import 'core/repositories/task_repository.dart';
import 'core/bloc/user_cubit.dart';
import 'core/bloc/availability_cubit.dart';
import 'core/bloc/task_cubit.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

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
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        home: BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            if (state is UserLoaded && state.currentUser != null) {
              return const HomePage();
            } else {
              return const OnboardingPage();
            }
          },
        ),
      ),
    );
  }
}
