import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'cl_profile_event.dart';
part 'cl_profile_state.dart';

@injectable
class ClProfileBloc extends Bloc<ClProfileEvent, ClProfileState> {
  ClProfileBloc() : super(ClProfileState()) {
    on<ClProfileEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
