import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/bloc/availability_cubit.dart';
import '../../core/bloc/user_cubit.dart';
import '../../core/utils/error_handler.dart';

class AddAvailabilityPage extends StatefulWidget {
  const AddAvailabilityPage({super.key});

  @override
  State<AddAvailabilityPage> createState() => _AddAvailabilityPageState();
}

class _AddAvailabilityPageState extends State<AddAvailabilityPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _startTime = const TimeOfDay(hour: 9, minute: 0);
    _endTime = const TimeOfDay(hour: 17, minute: 0);
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null) {
      setState(() {
        _startTime = time;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 17, minute: 0),
    );

    if (time != null) {
      setState(() {
        _endTime = time;
      });
    }
  }

  Future<void> _saveAvailability() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Validate that end time is after start time
    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ErrorHandler.showError(context, 'End time must be after start time');
      return;
    }

    // Validate that the duration is at least 15 minutes
    final duration = endDateTime.difference(startDateTime);
    if (duration.inMinutes < 15) {
      ErrorHandler.showError(
        context,
        'Availability slot must be at least 15 minutes long',
      );
      return;
    }

    // Validate that the slot is not in the past
    if (startDateTime.isBefore(DateTime.now())) {
      ErrorHandler.showError(
        context,
        'Cannot add availability slots in the past',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userState = context.read<UserCubit>().state;
      if (userState is UserLoaded && userState.currentUser != null) {
        await context.read<AvailabilityCubit>().addAvailability(
          userId: userState.currentUser!.id,
          startTime: startDateTime,
          endTime: endDateTime,
        );

        ErrorHandler.showSuccess(context, 'Availability added successfully!');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ErrorHandler.showError(
        context,
        'Failed to add availability. Please try again.',
      );
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
        title: const Text('Add Availability'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Selection
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // Start Time Selection
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Start Time'),
                  subtitle: Text(
                    _startTime != null
                        ? _startTime!.format(context)
                        : 'Select start time',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectStartTime,
                ),
              ),
              const SizedBox(height: 16),

              // End Time Selection
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('End Time'),
                  subtitle: Text(
                    _endTime != null
                        ? _endTime!.format(context)
                        : 'Select end time',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectEndTime,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Availability',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
