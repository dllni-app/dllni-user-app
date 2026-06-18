import 'package:common_package/common_package.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/login_response_model.dart';
import '../../../data/models/register_response_model.dart';
import '../../../domain/usecases/login_params.dart';
import '../../../domain/usecases/login_use_case.dart';
import '../../../domain/usecases/register_params.dart';
import '../../../domain/usecases/register_use_case.dart';
import '../../../domain/usecases/verify_account_params.dart';
import '../../../domain/usecases/verify_account_use_case.dart';

part 'auth_event.dart';

part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyAccountUseCase verifyAccountUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyAccountUseCase,
  }) : super(AuthState()) {
    on<LoginSubmittedEvent>(_onLoginSubmitted);
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
    on<VerifyAccountSubmittedEvent>(_onVerifyAccountSubmitted);
  }

  Future<void> _ensurePushTokenStored() async {
    await NotificationHelper.getToken(LoginParams.fcmTokenPrefsKey);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _ensurePushTokenStored();
    emit(
      AuthState(
        loginStatus: BlocStatus.loading,
        errorMessage: null,
        loginResult: null,
        registerStatus: state.registerStatus,
        registerErrorMessage: state.registerErrorMessage,
        registerResult: state.registerResult,
        verifyAccountStatus: state.verifyAccountStatus,
        verifyAccountErrorMessage: state.verifyAccountErrorMessage,
        verifyAccountResult: state.verifyAccountResult,
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
          verifyAccountStatus: state.verifyAccountStatus,
          verifyAccountErrorMessage: state.verifyAccountErrorMessage,
          verifyAccountResult: state.verifyAccountResult,
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
          verifyAccountStatus: state.verifyAccountStatus,
          verifyAccountErrorMessage: state.verifyAccountErrorMessage,
          verifyAccountResult: state.verifyAccountResult,
        ),
      ),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _ensurePushTokenStored();
    emit(
      AuthState(
        loginStatus: state.loginStatus,
        errorMessage: state.errorMessage,
        loginResult: state.loginResult,
        registerStatus: BlocStatus.loading,
        registerErrorMessage: null,
        registerResult: null,
        verifyAccountStatus: state.verifyAccountStatus,
        verifyAccountErrorMessage: state.verifyAccountErrorMessage,
        verifyAccountResult: state.verifyAccountResult,
      ),
    );
    final response = await registerUseCase(
      RegisterParams(
        name: event.name,
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
          verifyAccountStatus: state.verifyAccountStatus,
          verifyAccountErrorMessage: state.verifyAccountErrorMessage,
          verifyAccountResult: state.verifyAccountResult,
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
          verifyAccountStatus: state.verifyAccountStatus,
          verifyAccountErrorMessage: state.verifyAccountErrorMessage,
          verifyAccountResult: state.verifyAccountResult,
        ),
      ),
    );
  }

  Future<void> _onVerifyAccountSubmitted(
    VerifyAccountSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _ensurePushTokenStored();
    emit(
      AuthState(
        loginStatus: state.loginStatus,
        errorMessage: state.errorMessage,
        loginResult: state.loginResult,
        registerStatus: state.registerStatus,
        registerErrorMessage: state.registerErrorMessage,
        registerResult: state.registerResult,
        verifyAccountStatus: BlocStatus.loading,
        verifyAccountErrorMessage: null,
        verifyAccountResult: null,
      ),
    );
    final response = await verifyAccountUseCase(
      VerifyAccountParams(phone: event.phone, otp: event.otp),
    );
    response.fold(
      (failure) => emit(
        AuthState(
          loginStatus: state.loginStatus,
          errorMessage: state.errorMessage,
          loginResult: state.loginResult,
          registerStatus: state.registerStatus,
          registerErrorMessage: state.registerErrorMessage,
          registerResult: state.registerResult,
          verifyAccountStatus: BlocStatus.failed,
          verifyAccountErrorMessage: failure.message,
          verifyAccountResult: null,
        ),
      ),
      (result) => emit(
        AuthState(
          loginStatus: state.loginStatus,
          errorMessage: state.errorMessage,
          loginResult: state.loginResult,
          registerStatus: state.registerStatus,
          registerErrorMessage: state.registerErrorMessage,
          registerResult: state.registerResult,
          verifyAccountStatus: BlocStatus.success,
          verifyAccountErrorMessage: null,
          verifyAccountResult: result,
        ),
      ),
    );
  }
}
