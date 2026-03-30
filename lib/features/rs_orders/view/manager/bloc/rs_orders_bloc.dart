import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'rs_orders_event.dart';
part 'rs_orders_state.dart';

@injectable
class RsOrdersBloc extends Bloc<RsOrdersEvent, RsOrdersState> {
  RsOrdersBloc() : super(RsOrdersState()) {
    on<RsOrdersEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
