import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'rs_offers_event.dart';
part 'rs_offers_state.dart';

@injectable
class RsOffersBloc extends Bloc<RsOffersEvent, RsOffersState> {
  RsOffersBloc() : super(RsOffersState()) {
    on<RsOffersEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
