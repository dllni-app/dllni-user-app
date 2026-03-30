import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'sm_stores_event.dart';
part 'sm_stores_state.dart';

@injectable
class SmStoresBloc extends Bloc<SmStoresEvent, SmStoresState> {
  SmStoresBloc() : super(SmStoresState()) {
    on<SmStoresEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
