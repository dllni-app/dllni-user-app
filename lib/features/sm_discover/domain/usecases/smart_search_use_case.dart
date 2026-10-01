import 'package:common_package/helpers/typedef.dart';

import '../../data/models/smart_search_model.dart';
import '../repository/sm_discover_repo.dart';

class SmartSearchUseCase
    implements UseCase<SmartSearchModel, SmartSearchParams> {
  SmartSearchUseCase({required this.smDiscover});

  final SmDiscoverRepo smDiscover;

  @override
  DataResponse<SmartSearchModel> call(SmartSearchParams params) {
    return smDiscover.smartSearch(params);
  }
}

class SmartSearchParams with Params {
  SmartSearchParams({
    required this.query,
    required this.isSupermarket,
    this.locale = 'ar',
    this.topK = 20,
  });

  final String query;
  final bool isSupermarket;
  final String locale;
  final int topK;

  @override
  BodyMap getBody() => <String, dynamic>{
    'section': isSupermarket ? 'supermarket' : 'restaurant',
    'query': query,
    'locale': locale,
    'topK': topK,
  };
}
