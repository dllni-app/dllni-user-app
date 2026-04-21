import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingList extends StatelessWidget {
  const LoadingList({
    super.key,
    this.heightCard = 100,
    this.borderRadius = 16,
    this.length = 3,
  });
  final double heightCard;
  final double borderRadius;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, index) => Container(
          width: context.width,
          height: heightCard,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
        ),
        separatorBuilder: (_, _) => SizedBox(height: 12),
        itemCount: length,
      ),
    );
  }
}

class LoadingGrid extends StatelessWidget {
  const LoadingGrid({
    super.key,
    this.heightCard = 100,
    this.borderRadius = 16,
    this.length = 3,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 8,
  });
  final double heightCard;
  final double borderRadius;
  final int length;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisExtent: heightCard,
        ),
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, index) => Container(
          width: context.width,
          height: heightCard,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          ),
        ),
        // separatorBuilder: (_, _) => SizedBox(height: 12),
        itemCount: length,
      ),
    );
  }
}
