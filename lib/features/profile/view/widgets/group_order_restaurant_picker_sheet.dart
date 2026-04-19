import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../rs_discover/data/models/fetch_discover_restaurants_model.dart';
import '../manager/bloc/profile_bloc.dart';

class GroupOrderRestaurantPickerSheet {
  static Future<FetchDiscoverRestaurantsModelDataItem?> show(
    BuildContext context,
  ) {
    final searchController = TextEditingController();
    final bloc = context.read<ProfileBloc>();
    return showModalBottomSheet<FetchDiscoverRestaurantsModelDataItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.onPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.titleMedium(
                  'حدد المطعم',
                  color: context.primary,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مطعم',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        bloc.add(
                          FetchGroupOrderRestaurantsEvent(
                            searchQuery: searchController.text,
                          ),
                        );
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    bloc.add(FetchGroupOrderRestaurantsEvent(searchQuery: value));
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<ProfileBloc, ProfileState>(
                  bloc: bloc,
                  builder: (context, state) {
                    if (state.groupOrderRestaurantsStatus == BlocStatus.loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state.groupOrderRestaurantsStatus == BlocStatus.failed) {
                      return Column(
                        children: [
                          AppText.bodyMedium(
                            state.errorMessage ?? 'تعذر تحميل المطاعم',
                            color: const Color(0xff6B7280),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () {
                              bloc.add(
                                FetchGroupOrderRestaurantsEvent(
                                  searchQuery: searchController.text,
                                ),
                              );
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      );
                    }

                    final restaurants = state.groupOrderRestaurants;
                    if (restaurants.isEmpty) {
                      return AppText.bodyMedium(
                        'لا توجد نتائج',
                        color: const Color(0xff6B7280),
                      );
                    }

                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final restaurant = restaurants[index];
                          final isSelected =
                              state.selectedGroupOrderRestaurant?.id == restaurant.id;
                          return ListTile(
                            onTap: () => Navigator.of(modalContext).pop(restaurant),
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AppImage.network(
                                restaurant.imageUrl ??
                                    restaurant.primaryImage ??
                                    restaurant.image ??
                                    '',
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: AppText.bodyMedium(
                              restaurant.name ?? '-',
                              fontWeight: FontWeight.w700,
                            ),
                            subtitle: AppText.bodySmall(
                              restaurant.cuisineTypes
                                      ?.map((e) => e.name)
                                      .whereType<String>()
                                      .join(' • ') ??
                                  '',
                              color: const Color(0xff6B7280),
                            ),
                            trailing: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? context.primary
                                  : const Color(0xff9CA3AF),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemCount: restaurants.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
