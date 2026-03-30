import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'sm_home_event.dart';
part 'sm_home_state.dart';

@injectable
class SmHomeBloc extends Bloc<SmHomeEvent, SmHomeState> {
  SmHomeBloc() : super(SmHomeState()) {
    on<SmHomeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
