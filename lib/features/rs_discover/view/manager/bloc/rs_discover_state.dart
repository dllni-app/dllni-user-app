part of 'rs_discover_bloc.dart';

class RsDiscoverState {
  const RsDiscoverState({
    required this.filterOptions,
    required this.restaurants,
    required this.visibleRestaurants,
    this.selectedFilterIndex = 0,
    this.selectedSort = RsDiscoverSort.nearest,
  });

  factory RsDiscoverState.initial() {
    final options = <RsDiscoverFilterOption>[
      const RsDiscoverFilterOption(label: 'الكل', icon: Icons.grid_view_rounded),
      const RsDiscoverFilterOption(label: 'الأقرب', icon: Icons.location_on_outlined),
      const RsDiscoverFilterOption(
        label: 'الأعلى تقييماً',
        icon: Icons.star_rounded,
      ),
      const RsDiscoverFilterOption(
        label: 'التسليم الأسرع',
        icon: Icons.flash_on_rounded,
      ),
      const RsDiscoverFilterOption(label: 'يوجد عروض', icon: Icons.local_offer_outlined),
      const RsDiscoverFilterOption(label: 'مفتوح الآن', icon: Icons.access_time_rounded),
    ];

    final seededRestaurants = <RsRestaurantListItem>[
      const RsRestaurantListItem(
        id: 'italian-chef',
        name: 'مطعم الشيف الإيطالي',
        categoryLabel: 'إيطالي - بيتزا - باستا',
        heroImageUrl:
            'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80',
        rating: 4.5,
        reviewCountLabel: '1.2k',
        deliveryTimeLabel: '20-30 دقيقة',
        deliveryFeeLabel: 'توصيل 15 ل.س',
        distanceLabel: '1.2 كم',
        discountLabel: 'خصم %20',
        isNearby: true,
        hasOffer: true,
        isOpen: true,
      ),
      const RsRestaurantListItem(
        id: 'burger-factory',
        name: 'برجر فاكتوري',
        categoryLabel: 'برجر - أمريكي - وجبات سريعة',
        heroImageUrl:
            'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1200&q=80',
        rating: 4.8,
        reviewCountLabel: '980',
        deliveryTimeLabel: '35-45 دقيقة',
        deliveryFeeLabel: 'توصيل 10 ل.س',
        distanceLabel: '2.5 كم',
        isFastDelivery: false,
        isOpen: true,
      ),
      const RsRestaurantListItem(
        id: 'shawarma-house',
        name: 'بيت الشاورما',
        categoryLabel: 'شاورما - مشويات - عربي',
        heroImageUrl:
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=1200&q=80',
        rating: 4.7,
        reviewCountLabel: '2.1k',
        deliveryTimeLabel: '25-35 دقيقة',
        deliveryFeeLabel: 'توصيل مجاني',
        distanceLabel: '0.8 كم',
        badgeLabel: 'الأكثر طلباً',
        isFastDelivery: true,
        isNearby: true,
        isOpen: true,
      ),
      const RsRestaurantListItem(
        id: 'grill-garden',
        name: 'حديقة المشاوي',
        categoryLabel: 'مشاوي - عربي - شرقي',
        heroImageUrl:
            'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=1200&q=80',
        rating: 4.4,
        reviewCountLabel: '660',
        deliveryTimeLabel: '30-40 دقيقة',
        deliveryFeeLabel: 'توصيل 8 ل.س',
        distanceLabel: '3.1 كم',
        discountLabel: 'خصم %15',
        hasOffer: true,
        isFastDelivery: true,
        isOpen: false,
      ),
    ];

    return RsDiscoverState(
      filterOptions: options,
      restaurants: seededRestaurants,
      visibleRestaurants: seededRestaurants,
    );
  }

  final List<RsDiscoverFilterOption> filterOptions;
  final List<RsRestaurantListItem> restaurants;
  final List<RsRestaurantListItem> visibleRestaurants;
  final int selectedFilterIndex;
  final RsDiscoverSort selectedSort;

  RsDiscoverState copyWith({
    List<RsDiscoverFilterOption>? filterOptions,
    List<RsRestaurantListItem>? restaurants,
    List<RsRestaurantListItem>? visibleRestaurants,
    int? selectedFilterIndex,
    RsDiscoverSort? selectedSort,
  }) {
    return RsDiscoverState(
      filterOptions: filterOptions ?? this.filterOptions,
      restaurants: restaurants ?? this.restaurants,
      visibleRestaurants: visibleRestaurants ?? this.visibleRestaurants,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      selectedSort: selectedSort ?? this.selectedSort,
    );
  }
}
