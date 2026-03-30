import 'package:common_package/helpers/error_handler.dart';
import 'package:injectable/injectable.dart';

import '../../domain/models/rs_personal_details_update_input.dart';
import '../../domain/repository/rs_profile_repo.dart';

@LazySingleton(as: RsProfileRepo)
class RsProfileRepoImpl with HandlingException implements RsProfileRepo {
  @override
  Future<void> updatePersonalDetails(RsPersonalDetailsUpdateInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }
}

