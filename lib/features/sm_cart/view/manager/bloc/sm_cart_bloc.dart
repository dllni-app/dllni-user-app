import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'sm_cart_event.dart';
part 'sm_cart_state.dart';

@injectable
class SmCartBloc extends Bloc<SmCartEvent, SmCartState> {
  SmCartBloc() : super(SmCartState()) {
    on<SmCartEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
