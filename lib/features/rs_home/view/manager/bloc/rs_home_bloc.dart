import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'rs_home_event.dart';
part 'rs_home_state.dart';

@injectable
class RsHomeBloc extends Bloc<RsHomeEvent, RsHomeState> {
  RsHomeBloc() : super(RsHomeState()) {
    on<RsHomeEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
