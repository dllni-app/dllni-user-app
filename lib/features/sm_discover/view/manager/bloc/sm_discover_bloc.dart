import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'sm_discover_event.dart';
part 'sm_discover_state.dart';

@injectable
class SmDiscoverBloc extends Bloc<SmDiscoverEvent, SmDiscoverState> {
  SmDiscoverBloc() : super(SmDiscoverState()) {
    on<SmDiscoverEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
