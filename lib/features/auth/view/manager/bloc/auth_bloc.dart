import 'dart:convert';

import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/session/user_session_store.dart';
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

const String authFlowErrorPrefix = 'AUTH_FLOW::';

String encodeAuthFlowFailure(Failure failure) {
  final code = failure.code;
  if (code == null || code.isEmpty) return failure.message;

  return '$authFlowErrorPrefix${jsonEncode({
        'code': code,
        'message': failure.message,
        'data': failure.data ?? <String, dynamic>{},
      })}';
}

Map<String, dynamic>? _decodeAuthFlowPayload(String? raw) {
  final value = raw ?? '';
  if (!value.startsWith(authFlowErrorPrefix)) return null;

  try {
    final decoded = jsonDecode(value.substring(authFlowErrorPrefix.length));
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

String authFlowMessage(String? raw, {String fallback = ''}) {
  final payload = _decodeAuthFlowPayload(raw);
  if (payload == null) return (raw == null || raw.isEmpty) ? fallback : raw;

  final message = payload['message']?.toString() ?? '';
  return message.isEmpty ? fallback : message;
}

bool authFlowHasCode(String? raw, String code) {
  final payload = _decodeAuthFlowPayload(raw);
  return payload?['code']?.toString() == code || (raw ?? '').contains(code);
}

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

  Future<void> _saveLoggedInUser(LoggedInUserModel? user) async {
    if (user == null) {
      await UserSessionStore.clearUserProfile();
      return;
    }

    await UserSessionStore.writeAndMirror(user);
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

    await response.fold(
      (failure) async {
        emit(
          AuthState(
            loginStatus: BlocStatus.failed,
            errorMessage: encodeAuthFlowFailure(failure),
            loginResult: null,
            registerStatus: state.registerStatus,
            registerErrorMessage: state.registerErrorMessage,
            registerResult: state.registerResult,
            verifyAccountStatus: state.verifyAccountStatus,
            verifyAccountErrorMessage: state.verifyAccountErrorMessage,
            verifyAccountResult: state.verifyAccountResult,
          ),
        );
      },
      (result) async {
        await _saveLoggedInUser(result.data);

        emit(
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
        );
      },
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
          registerErrorMessage: encodeAuthFlowFailure(failure),
          registerResult: null,
          verifyAccountStatus: state.verifyAccountStatus,
          verifyAccountErrorMessage: state.verifyAccountErrorMessage,
          verifyAccountResult: state.verifyAccountResult,
        ),
      ),
      (result) {
        emit(
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
        );
      },
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

    await response.fold(
      (failure) async {
        emit(
          AuthState(
            loginStatus: state.loginStatus,
            errorMessage: state.errorMessage,
            loginResult: state.loginResult,
            registerStatus: state.registerStatus,
            registerErrorMessage: state.registerErrorMessage,
            registerResult: state.registerResult,
            verifyAccountStatus: BlocStatus.failed,
            verifyAccountErrorMessage: encodeAuthFlowFailure(failure),
            verifyAccountResult: null,
          ),
        );
      },
      (result) async {
        await _saveLoggedInUser(result.data);

        emit(
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
        );
      },
    );
  }
}
