import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dllni_user_app/core/widgets/design_system/design_system.dart';

void main() {
  test('V6 palette matches approved reference', () {
    expect(AlnadhaTokens.primary, const Color(0xFF172554));
    expect(AlnadhaTokens.background, const Color(0xFFF6F7F9));
    expect(AppSection.cleaning.accent, const Color(0xFF365487));
    expect(AppSection.cleaning.ink, const Color(0xFF172554));
    expect(AppSection.cleaning.soft, const Color(0xFFEEF2F9));
    expect(AppSection.restaurant.accent, const Color(0xFFA63C66));
    expect(AppSection.supermarket.accent, const Color(0xFF168A67));
    expect(AppSection.delivery.accent, const Color(0xFF5D62B1));
    expect(AlnadhaTokens.controlHeight, 52);
    expect(AlnadhaTokens.minimumTouchSize, greaterThanOrEqualTo(48));
  });
}
