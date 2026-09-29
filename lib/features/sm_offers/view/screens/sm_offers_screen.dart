import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../sm_home/data/models/get_featured_offers_model.dart';
import '../../../sm_home/data/source/sm_home_remote_data_source.dart';
import '../../../sm_home/domain/usecases/get_featured_offers_use_case.dart';
import '../../../sm_stores/view/screens/sm_store_details_screen.dart';

@AutoRoutePage(path: "/sm_offers")
class SmOffersScreen extends StatefulWidget {
  const SmOffersScreen({super.key});

  @override
  State<SmOffersScreen> createState() => _SmOffersScreenState();
}

class _SmOffersScreenState extends State<SmOffersScreen> {
  late Future<GetFeaturedOffersModel> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = getIt<SmHomeRemoteDataSource>().getFeaturedOffers(
      GetFeaturedOffersParams(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: "العروض",
            arrowBackType: ArrowBackType.cupertino,
            canPop: context.canPop(),
          ),
          Expanded(
            child: FutureBuilder<GetFeaturedOffersModel>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return FailureWidget(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(_reload),
                  );
                }
                final offers = snapshot.data?.offers ?? const [];
                if (offers.isEmpty) {
                  return const Center(child: Text('لا توجد عروض متاحة حالياً'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(_reload);
                    await _future;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: offers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final offer = offers[index];
                      final storeId = offer.store?.id;
                      final discount = offer.discountPercent != null
                          ? offer.discountPercent.toString() + '%'
                          : (offer.discountValue?.toString() ?? '') + ' ل.س';
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: SizedBox(
                            width: 64,
                            height: 64,
                            child: AppImage.network(
                              offer.imageUrl ?? offer.store?.cover ?? '',
                              fit: BoxFit.cover,
                              errorWidget: const Icon(
                                Icons.local_offer_outlined,
                              ),
                            ),
                          ),
                          title: Text(offer.name ?? 'عرض'),
                          subtitle: Text(
                            (offer.description ?? '') + '\nخصم ' + discount,
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_left),
                          onTap: storeId == null
                              ? null
                              : () => context.pushRoute(
                                  '/store',
                                  arguments: SmStoreDetailsScreenArgs(
                                    storeId: storeId,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
