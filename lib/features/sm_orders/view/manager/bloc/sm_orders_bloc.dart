import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'sm_orders_event.dart';
part 'sm_orders_state.dart';

@injectable
class SmOrdersBloc extends Bloc<SmOrdersEvent, SmOrdersState> {
  SmOrdersBloc() : super(SmOrdersState()) {
    on<SmOrdersEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
