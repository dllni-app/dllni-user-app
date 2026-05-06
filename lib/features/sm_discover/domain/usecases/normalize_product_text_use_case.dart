import 'package:injectable/injectable.dart';
import 'package:common_package/helpers/typedef.dart';

import '../repository/sm_discover_repo.dart';
import '../../data/models/normalize_product_text_model.dart';

@lazySingleton
class NormalizeProductTextUseCase
    implements UseCase<NormalizeProductTextModel, NormalizeProductTextParams> {
  final SmDiscoverRepo smDiscover;

  NormalizeProductTextUseCase({required this.smDiscover});

  @override
  DataResponse<NormalizeProductTextModel> call(
    NormalizeProductTextParams params,
  ) {
    return smDiscover.normalizeProductText(params);
  }
}

class NormalizeProductTextParams with Params {
  final String text;
  final String locale;
  final bool isSupermarket;
  NormalizeProductTextParams({
    required this.text,
    this.locale = 'ar',
    required this.isSupermarket,
  });

  @override
  BodyMap getBody() => {
    'text': text,
    'locale': locale,
    'module': isSupermarket ? 'supermarket' : 'restaurant',
  };
}
