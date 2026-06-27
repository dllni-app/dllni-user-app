

import 'package:common_package/annotations/auto_route_page.dart';

import 'package:flutter/material.dart';

@AutoRoutePage(path: '/termsAndConditions')
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: Container(),

    );
  }
}
