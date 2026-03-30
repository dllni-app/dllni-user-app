import '../models/rs_personal_details_update_input.dart';

abstract class RsProfileRepo {
  Future<void> updatePersonalDetails(RsPersonalDetailsUpdateInput input);
}
