import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/user_cubit.dart';
import '../../core/bloc/task_cubit.dart';
import 'task_list_page.dart';
import 'availability_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [const TaskListPage(), const AvailabilityPage()];

  @override
  void initState() {
    super.initState();
    // Load tasks when the home page is initialized
    context.read<TaskCubit>().loadAllTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Scheduler'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              if (state is UserLoaded && state.currentUser != null) {
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: state.currentUser!.photoUrl != null
                          ? NetworkImage(state.currentUser!.photoUrl!)
                          : null,
                      child: state.currentUser!.photoUrl == null
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.currentUser!.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Availability',
          ),
        ],
      ),
    );
  }
}
