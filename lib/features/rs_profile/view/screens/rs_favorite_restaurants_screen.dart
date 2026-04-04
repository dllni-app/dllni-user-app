import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/fetch_favorite_restaurants_use_case.dart';
import '../manager/bloc/rs_profile_bloc.dart';

@AutoRoutePage()
class RsFavoriteRestaurantsScreen extends StatefulWidget {
  const RsFavoriteRestaurantsScreen({super.key});

  @override
  State<RsFavoriteRestaurantsScreen> createState() =>
      _RsFavoriteRestaurantsScreenState();
}

class _RsFavoriteRestaurantsScreenState
    extends State<RsFavoriteRestaurantsScreen> {
  Future<void> _reload() async {
    final bloc = context.read<RsProfileBloc>();
    bloc.add(
      FetchFavoriteRestaurantsEvent(params: FetchFavoriteRestaurantsParams()),
    );
    await bloc.stream.firstWhere(
      (state) => state.favoriteRestaurantsStatus != BlocStatus.loading,
    );
  }

  void _removeFavorite(int restaurantId) {
    context.read<RsProfileBloc>().add(
      RemoveFavoriteRestaurantEvent(restaurantId: restaurantId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RsProfileBloc>(
      lazy: false,
      create: (_) => getIt<RsProfileBloc>()
        ..add(
          FetchFavoriteRestaurantsEvent(
            params: FetchFavoriteRestaurantsParams(),
          ),
        ),
      child: BlocListener<RsProfileBloc, RsProfileState>(
        listenWhen: (previous, current) =>
            previous.removeFavoriteRestaurantStatus !=
                current.removeFavoriteRestaurantStatus ||
            (previous.favoriteRestaurantsStatus !=
                    current.favoriteRestaurantsStatus &&
                current.favoriteRestaurantsStatus == BlocStatus.failed),
        listener: (context, state) {
          if (state.removeFavoriteRestaurantStatus == BlocStatus.success &&
              state.actionMessage != null &&
              state.actionMessage!.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.actionMessage!)));
            return;
          }
          if (state.errorMessage == null || state.errorMessage!.isEmpty) {
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('المطاعم المفضلة')),
          body: BlocBuilder<RsProfileBloc, RsProfileState>(
            builder: (context, state) {
              if (state.favoriteRestaurantsStatus == null ||
                  state.favoriteRestaurantsStatus == BlocStatus.loading ||
                  state.favoriteRestaurantsStatus == BlocStatus.init) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = state.favoriteRestaurants;
              if (list.isEmpty) {
                return const Center(child: Text('لا توجد مطاعم مفضلة'));
              }
              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final item = list[i];
                    final id = item.id;
                    return ListTile(
                      title: Text(item.name ?? '-'),
                      subtitle: Text(item.slug ?? ''),
                      trailing: id == null
                          ? null
                          : IconButton(
                              onPressed: () => _removeFavorite(id),
                              icon: const Icon(Icons.favorite, color: Colors.red),
                            ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
