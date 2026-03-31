import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'sm_profile_event.dart';
part 'sm_profile_state.dart';

@injectable
class SmProfileBloc extends Bloc<SmProfileEvent, SmProfileState> {
  SmProfileBloc() : super(SmProfileState()) {
    on<SmProfileEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
