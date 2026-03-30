import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'cl_home_event.dart';
part 'cl_home_state.dart';

@injectable
class ClHomeBloc extends Bloc<ClHomeEvent, ClHomeState> {
  ClHomeBloc() : super(ClHomeState()) {
    on<ClHomeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
