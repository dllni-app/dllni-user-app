import 'package:common_package/common_package.dart';
import 'package:dio/dio.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_models.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DeepLinkRemoteDataSource {
  DeepLinkRemoteDataSource({required this.dioNetwork});

  final DioNetwork dioNetwork;

  /// Returns null on transport/parse failure or HTTP 422 (validation).
  Future<DeepLinkResolveResult?> resolve(String url) async {
    try {
      final response = await dioNetwork.postData(
        endPoint: '/api/v1/deep-links/resolve',
        data: <String, dynamic>{'url': url},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return DeepLinkResolveResult.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      if (status == 422 && data is Map<String, dynamic>) {
        return null;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Best-effort server analytics (optional auth).
  Future<void> postDeepLinkEvent({
    required String action,
    String? url,
    String? source,
    String? medium,
    String? campaign,
    int? sharerId,
    required String platform,
  }) async {
    try {
      final data = <String, dynamic>{
        'action': action,
        if (url?.isNotEmpty ?? false) 'url': url!,
        if (source != null && source.isNotEmpty) 'source': source,
        if (medium != null && medium.isNotEmpty) 'medium': medium,
        if (campaign != null && campaign.isNotEmpty) 'campaign': campaign,
        'platform': platform,
      };
      if (sharerId != null) {
        data['sharer_id'] = sharerId;
      }

      await dioNetwork.postData(
        endPoint: '/api/v1/deep-links/events',
        data: data,
      );
    } catch (_) {}
  }
}
