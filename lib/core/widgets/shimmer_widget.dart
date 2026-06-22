
import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({
    super.key,
    this.width,
    this.height,
    this.border,
    this.shape = BoxShape.rectangle,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final Border? border;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Shimmer.fromColors(
        baseColor:context.primary.withOpacity(.5),
        highlightColor: context.primary,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color:    context.primary,
            shape: shape,
            border: border,
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
  }
}
