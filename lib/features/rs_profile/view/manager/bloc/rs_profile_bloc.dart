import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'rs_profile_event.dart';
part 'rs_profile_state.dart';

@injectable
class RsProfileBloc extends Bloc<RsProfileEvent, RsProfileState> {
  RsProfileBloc() : super(RsProfileState()) {
    on<RsProfileEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
