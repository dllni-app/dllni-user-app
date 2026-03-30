import 'dart:convert';

import 'package:common_package/common_package.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';
import '../../../domain/usecases/login_use_case.dart';
import '../../../data/models/login_model.dart';

part 'auth_event.dart';

part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthState()) {
    on<LoginEvent>(_login);
  }

  FutureOr<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginStatus: BlocStatus.loading));
    final res = await loginUseCase(event.params);
    res.fold(
      (l) {
        emit(state.copyWith(loginStatus: BlocStatus.failed, errorMessage: l.message));
      },
      (r) {
        SharedPreferencesHelper.saveData(key: 'token', value: r.token);
        SharedPreferencesHelper.saveData(key: 'user', value: json.encode(r));
        emit(state.copyWith(loginStatus: BlocStatus.success, login: r));
      },
    );
  }
}
