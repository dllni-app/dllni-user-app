import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'cl_booking_event.dart';
part 'cl_booking_state.dart';

@injectable
class ClBookingBloc extends Bloc<ClBookingEvent, ClBookingState> {
  ClBookingBloc() : super(ClBookingState()) {
    on<ClBookingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
