import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'cl_offers_event.dart';
part 'cl_offers_state.dart';

@injectable
class ClOffersBloc extends Bloc<ClOffersEvent, ClOffersState> {
  ClOffersBloc() : super(ClOffersState()) {
    on<ClOffersEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
