import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'rs_main_event.dart';
part 'rs_main_state.dart';

@injectable
class RsMainBloc extends Bloc<RsMainEvent, RsMainState> {
  RsMainBloc() : super(RsMainState()) {
    on<RsMainEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
