import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

// Events
abstract class UserEvent {}

class LoadCurrentUser extends UserEvent {}

class CreateUser extends UserEvent {
  final String name;
  final String? photoUrl;

  CreateUser({required this.name, this.photoUrl});
}

class UpdateUser extends UserEvent {
  final String id;
  final String? name;
  final String? photoUrl;

  UpdateUser({required this.id, this.name, this.photoUrl});
}

class LoadAllUsers extends UserEvent {}

// States
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel? currentUser;
  final List<UserModel> allUsers;

  UserLoaded({this.currentUser, this.allUsers = const []});
}

class UserError extends UserState {
  final String message;

  UserError({required this.message});
}

// Cubit
class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;

  UserCubit({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(UserInitial());

  Future<void> loadCurrentUser() async {
    emit(UserLoading());
    try {
      final user = await _userRepository.getCurrentUser();
      emit(UserLoaded(currentUser: user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> createUser({required String name, String? photoUrl}) async {
    emit(UserLoading());
    try {
      final user = await _userRepository.createUser(
        name: name,
        photoUrl: photoUrl,
      );
      emit(UserLoaded(currentUser: user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> updateUser({
    required String id,
    String? name,
    String? photoUrl,
  }) async {
    emit(UserLoading());
    try {
      final user = await _userRepository.updateUser(
        id: id,
        name: name,
        photoUrl: photoUrl,
      );
      emit(UserLoaded(currentUser: user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> loadAllUsers() async {
    try {
      final users = await _userRepository.getAllUsers();
      final currentState = state;
      if (currentState is UserLoaded) {
        emit(
          UserLoaded(currentUser: currentState.currentUser, allUsers: users),
        );
      } else {
        emit(UserLoaded(allUsers: users));
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }
}
