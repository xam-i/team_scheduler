import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/user_cubit.dart';
import '../../core/bloc/availability_cubit.dart';
import '../../core/bloc/task_cubit.dart';
import '../../core/services/slot_finder_service.dart';
import '../../core/models/availability_model.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Task Details
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Step 2: Collaborators
  final List<String> _selectedCollaborators = [];

  // Step 3: Duration
  Duration _selectedDuration = const Duration(minutes: 30);
  final List<Duration> _durationOptions = [
    const Duration(minutes: 10),
    const Duration(minutes: 15),
    const Duration(minutes: 30),
    const Duration(minutes: 60),
  ];

  // Step 4: Time Slot
  TimeSlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    context.read<UserCubit>().loadAllUsers();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createTask();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        return _selectedCollaborators.isNotEmpty;
      case 2:
        return true; // Duration is always selected
      case 3:
        return _selectedSlot != null;
      default:
        return false;
    }
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedCollaborators.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final userState = context.read<UserCubit>().state;
      if (userState is! UserLoaded || userState.currentUser == null) return;

      final currentUserId = userState.currentUser!.id;
      final allUserIds = [currentUserId, ..._selectedCollaborators];

      // Load availability for all users
      final availabilityCubit = context.read<AvailabilityCubit>();
      final availabilities = await availabilityCubit
          .loadMultipleUsersAvailability(allUserIds);

      // Group availabilities by user
      Map<String, List<AvailabilityModel>> userAvailabilities = {};
      for (final availability in availabilities) {
        userAvailabilities
            .putIfAbsent(availability.userId, () => [])
            .add(availability);
      }

      // Convert to list of lists for slot finder
      List<List<AvailabilityModel>> availabilityLists = allUserIds
          .map((userId) => userAvailabilities[userId] ?? [])
          .toList();

      // Find common slots
      final commonSlots = SlotFinderService.findCommonSlots(
        userAvailabilities: availabilityLists,
        taskDuration: _selectedDuration,
      );

      setState(() {
        _availableSlots = commonSlots;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading slots: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TimeSlot> _availableSlots = [];

  Future<void> _createTask() async {
    if (_selectedSlot == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userState = context.read<UserCubit>().state;
      if (userState is! UserLoaded || userState.currentUser == null) return;

      await context.read<TaskCubit>().createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdBy: userState.currentUser!.id,
        collaboratorIds: _selectedCollaborators,
        startTime: _selectedSlot!.startTime,
        endTime: _selectedSlot!.endTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creating task: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task - Step ${_currentStep + 1}/4'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 16),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });

                // Load available slots when reaching step 4
                if (index == 3) {
                  _loadAvailableSlots();
                }
              },
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceedToNextStep() && !_isLoading
                        ? _nextStep
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_currentStep == 3 ? 'Create Task' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Collaborators',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoaded) {
                  final currentUser = state.currentUser;
                  final otherUsers = state.allUsers
                      .where((user) => user.id != currentUser?.id)
                      .toList();

                  return ListView.builder(
                    itemCount: otherUsers.length,
                    itemBuilder: (context, index) {
                      final user = otherUsers[index];
                      final isSelected = _selectedCollaborators.contains(
                        user.id,
                      );

                      return Card(
                        child: CheckboxListTile(
                          title: Text(user.name),
                          subtitle: user.photoUrl != null
                              ? CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(user.photoUrl!),
                                )
                              : null,
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedCollaborators.add(user.id);
                              } else {
                                _selectedCollaborators.remove(user.id);
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Duration',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _durationOptions.length,
              itemBuilder: (context, index) {
                final duration = _durationOptions[index];
                final minutes = duration.inMinutes;

                return Card(
                  child: RadioListTile<Duration>(
                    title: Text('$minutes minutes'),
                    subtitle: Text(_getDurationDescription(minutes)),
                    value: duration,
                    groupValue: _selectedDuration,
                    onChanged: (Duration? value) {
                      setState(() {
                        _selectedDuration = value!;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Available Slot',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_availableSlots.isEmpty)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No available slots found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No common time slots available for all collaborators',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _availableSlots.length,
                itemBuilder: (context, index) {
                  final slot = _availableSlots[index];

                  return Card(
                    child: RadioListTile<TimeSlot>(
                      title: Text(slot.toString()),
                      subtitle: Text(_formatDate(slot.startTime)),
                      value: slot,
                      groupValue: _selectedSlot,
                      onChanged: (TimeSlot? value) {
                        setState(() {
                          _selectedSlot = value;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _getDurationDescription(int minutes) {
    if (minutes < 30) {
      return 'Quick meeting';
    } else if (minutes < 60) {
      return 'Standard meeting';
    } else {
      return 'Long meeting';
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (slotDate == today) {
      return 'Today';
    } else if (slotDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
