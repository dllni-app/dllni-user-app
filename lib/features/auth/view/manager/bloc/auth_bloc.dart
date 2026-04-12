import 'package:common_package/common_package.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/login_response_model.dart';
import '../../../data/models/register_response_model.dart';
import '../../../domain/usecases/login_params.dart';
import '../../../domain/usecases/login_use_case.dart';
import '../../../domain/usecases/register_params.dart';
import '../../../domain/usecases/register_use_case.dart';

part 'auth_event.dart';

part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthState()) {
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      AuthState(
        loginStatus: BlocStatus.loading,
        errorMessage: null,
        loginResult: null,
        registerStatus: state.registerStatus,
        registerErrorMessage: state.registerErrorMessage,
        registerResult: state.registerResult,
      ),
    );
    final response = await loginUseCase(
      LoginParams(phone: event.phone, password: event.password),
    );
    response.fold(
      (failure) => emit(
        AuthState(
          loginStatus: BlocStatus.failed,
          errorMessage: failure.message,
          loginResult: null,
          registerStatus: state.registerStatus,
          registerErrorMessage: state.registerErrorMessage,
          registerResult: state.registerResult,
        ),
      ),
      (result) => emit(
        AuthState(
          loginStatus: BlocStatus.success,
          errorMessage: null,
          loginResult: result,
          registerStatus: state.registerStatus,
          registerErrorMessage: state.registerErrorMessage,
          registerResult: state.registerResult,
        ),
      ),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      AuthState(
        loginStatus: state.loginStatus,
        errorMessage: state.errorMessage,
        loginResult: state.loginResult,
        registerStatus: BlocStatus.loading,
        registerErrorMessage: null,
        registerResult: null,
      ),
    );
    final response = await registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
      ),
    );
    response.fold(
      (failure) => emit(
        AuthState(
          loginStatus: state.loginStatus,
          errorMessage: state.errorMessage,
          loginResult: state.loginResult,
          registerStatus: BlocStatus.failed,
          registerErrorMessage: failure.message,
          registerResult: null,
        ),
      ),
      (result) => emit(
        AuthState(
          loginStatus: state.loginStatus,
          errorMessage: state.errorMessage,
          loginResult: state.loginResult,
          registerStatus: BlocStatus.success,
          registerErrorMessage: null,
          registerResult: result,
        ),
      ),
    );
  }
}
