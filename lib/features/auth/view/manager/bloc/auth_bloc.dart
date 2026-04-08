import 'package:common_package/common_package.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/login_response_model.dart';
import '../../../domain/usecases/login_params.dart';
import '../../../domain/usecases/login_use_case.dart';

part 'auth_event.dart';

part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(AuthState()) {
    on<LoginSubmittedEvent>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState(loginStatus: BlocStatus.loading, errorMessage: null, loginResult: null));
    final response = await loginUseCase(
      LoginParams(phone: event.phone, password: event.password),
    );
    response.fold(
      (failure) => emit(
        AuthState(
          loginStatus: BlocStatus.failed,
          errorMessage: failure.message,
          loginResult: null,
        ),
      ),
      (result) => emit(
        AuthState(
          loginStatus: BlocStatus.success,
          errorMessage: null,
          loginResult: result,
        ),
      ),
    );
  }
}
