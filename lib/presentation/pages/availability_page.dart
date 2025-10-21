import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/availability_cubit.dart';
import '../../core/bloc/user_cubit.dart';
import 'add_availability_page.dart';

class AvailabilityPage extends StatefulWidget {
  const AvailabilityPage({super.key});

  @override
  State<AvailabilityPage> createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  @override
  void initState() {
    super.initState();
    _loadUserAvailability();
  }

  void _loadUserAvailability() {
    final userState = context.read<UserCubit>().state;
    if (userState is UserLoaded && userState.currentUser != null) {
      context.read<AvailabilityCubit>().loadUserAvailability(
        userState.currentUser!.id,
      );
    }
  }

  Future<void> _deleteAvailability(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Availability'),
        content: const Text(
          'Are you sure you want to delete this availability slot?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<AvailabilityCubit>().deleteAvailability(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AvailabilityCubit, AvailabilityState>(
        builder: (context, state) {
          if (state is AvailabilityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AvailabilityError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading availability',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserAvailability,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AvailabilityLoaded) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'My Availability',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Availability List
                Expanded(
                  child: state.availabilities.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No availability slots added yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add your available time slots to help your team schedule meetings',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.availabilities.length,
                          itemBuilder: (context, index) {
                            final availability = state.availabilities[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.access_time),
                                title: Text(
                                  '${_formatTime(availability.startTime)} - ${_formatTime(availability.endTime)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  _formatDate(availability.startTime),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _deleteAvailability(availability.id),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAvailabilityPage(),
            ),
          );

          if (result == true) {
            _loadUserAvailability();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final availabilityDate = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

    if (availabilityDate == today) {
      return 'Today';
    } else if (availabilityDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
