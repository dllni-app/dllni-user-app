/// Maps [discoverTabs] index (0–5) to API query fields.
class DiscoverTabQuery {
  final String sort;
  final int filterOpenNow;
  final int filterHasOffers;

  const DiscoverTabQuery({
    required this.sort,
    required this.filterOpenNow,
    required this.filterHasOffers,
  });

  static DiscoverTabQuery fromTabIndex(int index) {
    switch (index) {
      case 1:
        return const DiscoverTabQuery(sort: 'nearest', filterOpenNow: 0, filterHasOffers: 0);
      case 2:
        return const DiscoverTabQuery(sort: 'rating', filterOpenNow: 0, filterHasOffers: 0);
      case 3:
        return const DiscoverTabQuery(sort: 'fastest', filterOpenNow: 0, filterHasOffers: 0);
      case 4:
        return const DiscoverTabQuery(sort: 'rating', filterOpenNow: 0, filterHasOffers: 1);
      case 5:
        return const DiscoverTabQuery(sort: 'rating', filterOpenNow: 1, filterHasOffers: 0);
      case 0:
      default:
        return const DiscoverTabQuery(sort: 'rating', filterOpenNow: 0, filterHasOffers: 0);
    }
  }

  static String sortLabelAr(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 'الأقرب';
      case 2:
        return 'الأعلى تقييماً';
      case 3:
        return 'الأسرع توصيلاً';
      case 4:
        return 'يوجد عروض';
      case 5:
        return 'مفتوح الآن';
      case 0:
      default:
        return 'الكل';
    }
  }
}
