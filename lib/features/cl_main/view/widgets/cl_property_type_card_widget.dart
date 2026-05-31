import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../data/cl_main_route_args.dart';

class ClPropertyTypeCardWidget extends StatelessWidget {
  const ClPropertyTypeCardWidget({required this.title, required this.icon, required this.args, super.key});

  final String title;
  final String icon;
  final ClMainHomeDescriptionArgs args;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        context.pushRoute('/clmainhomedescription', arguments: args);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: AssetImage(icon), fit: BoxFit.cover),
        ),
        width: context.width,
        height: 200,
        padding: EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsetsDirectional.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [AppText.bodyMedium(title, fontWeight: FontWeight.w700, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
