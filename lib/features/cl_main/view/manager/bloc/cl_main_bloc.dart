import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'cl_main_event.dart';
part 'cl_main_state.dart';

@injectable
class ClMainBloc extends Bloc<ClMainEvent, ClMainState> {
  ClMainBloc() : super(ClMainState()) {
    on<ClMainEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
