part of 'rs_discover_bloc.dart';

abstract class RsDiscoverEvent {}

class RsDiscoverFilterChanged extends RsDiscoverEvent {
  RsDiscoverFilterChanged(this.filterIndex);

  final int filterIndex;
}

class RsDiscoverSortChanged extends RsDiscoverEvent {
  RsDiscoverSortChanged(this.sort);

  final RsDiscoverSort sort;
}
