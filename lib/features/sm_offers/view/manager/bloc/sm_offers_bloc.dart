import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'sm_offers_event.dart';
part 'sm_offers_state.dart';

@injectable
class SmOffersBloc extends Bloc<SmOffersEvent, SmOffersState> {
  SmOffersBloc() : super(SmOffersState()) {
    on<SmOffersEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
