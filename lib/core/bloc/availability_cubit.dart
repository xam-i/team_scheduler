import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/availability_model.dart';
import '../repositories/availability_repository.dart';

// Events
abstract class AvailabilityEvent {}

class LoadUserAvailability extends AvailabilityEvent {
  final String userId;

  LoadUserAvailability({required this.userId});
}

class AddAvailability extends AvailabilityEvent {
  final String userId;
  final DateTime startTime;
  final DateTime endTime;

  AddAvailability({
    required this.userId,
    required this.startTime,
    required this.endTime,
  });
}

class DeleteAvailability extends AvailabilityEvent {
  final int id;

  DeleteAvailability({required this.id});
}

class LoadMultipleUsersAvailability extends AvailabilityEvent {
  final List<String> userIds;

  LoadMultipleUsersAvailability({required this.userIds});
}

// States
abstract class AvailabilityState {}

class AvailabilityInitial extends AvailabilityState {}

class AvailabilityLoading extends AvailabilityState {}

class AvailabilityLoaded extends AvailabilityState {
  final List<AvailabilityModel> availabilities;

  AvailabilityLoaded({required this.availabilities});
}

class AvailabilityError extends AvailabilityState {
  final String message;

  AvailabilityError({required this.message});
}

// Cubit
class AvailabilityCubit extends Cubit<AvailabilityState> {
  final AvailabilityRepository _availabilityRepository;

  AvailabilityCubit({required AvailabilityRepository availabilityRepository})
    : _availabilityRepository = availabilityRepository,
      super(AvailabilityInitial());

  Future<void> loadUserAvailability(String userId) async {
    emit(AvailabilityLoading());
    try {
      final availabilities = await _availabilityRepository.getUserAvailability(
        userId,
      );
      emit(AvailabilityLoaded(availabilities: availabilities));
    } catch (e) {
      emit(AvailabilityError(message: e.toString()));
    }
  }

  Future<void> addAvailability({
    required String userId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      await _availabilityRepository.addAvailability(
        userId: userId,
        startTime: startTime,
        endTime: endTime,
      );
      await loadUserAvailability(userId);
    } catch (e) {
      emit(AvailabilityError(message: e.toString()));
    }
  }

  Future<void> deleteAvailability(int id) async {
    try {
      await _availabilityRepository.deleteAvailability(id);
      final currentState = state;
      if (currentState is AvailabilityLoaded) {
        final updatedAvailabilities = currentState.availabilities
            .where((availability) => availability.id != id)
            .toList();
        emit(AvailabilityLoaded(availabilities: updatedAvailabilities));
      }
    } catch (e) {
      emit(AvailabilityError(message: e.toString()));
    }
  }

  Future<List<AvailabilityModel>> loadMultipleUsersAvailability(
    List<String> userIds,
  ) async {
    try {
      return await _availabilityRepository.getMultipleUsersAvailability(
        userIds,
      );
    } catch (e) {
      emit(AvailabilityError(message: e.toString()));
      return [];
    }
  }
}
