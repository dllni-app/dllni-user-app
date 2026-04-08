import 'package:common_package/common_package.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

@AutoRoutePage(path: "/shopping_list_details")
class ShoppingListDetailsScreen extends StatelessWidget {
  const ShoppingListDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          const _ShoppingListDetailsHeader(title: "قائمة التسوق الذكي"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                spacing: 16,
                children: [
                  ListView.separated(
                    itemCount: 3,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, index) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Color(0x0D000000),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 12,
                        children: [
                          Row(
                            spacing: 12,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0x2B22C55E),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.bagShopping,
                                  size: 20,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              Expanded(
                                child: AppText(
                                  index == 0
                                      ? "ربطة خبز سياحي"
                                      : index == 1
                                          ? "علبة مرتديلا هنا"
                                          : "لبنة نيو بارك 250 غ",
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 24 / 16,
                                  ),
                                ),
                              ),
                              CupertinoSwitch(
                                value: true,
                                activeColor: const Color(0xFF43B654),
                                onChanged: (value) {},
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 32,
                            children: [
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: InkWell(
                                  onTap: () {},
                                  customBorder: const CircleBorder(),
                                  child: const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.minus,
                                      size: 24,
                                      color: Color(0xFF43B654),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: AppText(
                                  "1",
                                  style: TextStyle(
                                    color: Color(0xFF111827),
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    height: 40 / 36,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: InkWell(
                                  onTap: () {},
                                  customBorder: const CircleBorder(),
                                  child: const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.plus,
                                      size: 24,
                                      color: Color(0xFF43B654),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: context.width,
                            padding: const EdgeInsets.only(top: 14, bottom: 13),
                            decoration: BoxDecoration(
                              color: const Color(0x1464748B),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                              border: Border.all(color: const Color(0xFF94A3B8)),
                            ),
                            child: AppText(
                              "حذف المنتج من القائمة",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 16 / 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint("إعادة طلب هذه القائمة");
                    },
                    child: Container(
                      width: context.width,
                      padding: const EdgeInsets.only(top: 14, bottom: 13),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF7A00),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: AppText(
                        "إعادة طلب هذه  القائمة",
                        style: TextStyle(
                          color: Color(0xFFFFEEFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 16 / 14,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 22,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            debugPrint("تعديل قائمة التسوق");
                          },
                          child: Container(
                            padding: const EdgeInsets.only(top: 13, bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Color(0xFF1E3A8A)),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: AppText(
                              "تعديل قائمة التسوق",
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 16 / 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            debugPrint("حذف قائمة التسوق");
                          },
                          child: Container(
                            padding: const EdgeInsets.only(top: 13, bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFDC2626)),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: AppText(
                              "حذف قائمة التسوق",
                              style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 16 / 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingListDetailsHeader extends StatelessWidget {
  const _ShoppingListDetailsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.paddingOf(context).top, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFF1E3A8A), width: 2)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: const [BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0D000000))],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: AppText(
              title,
              style: const TextStyle(color: Color(0xFF1E3A8A), fontSize: 22, fontWeight: FontWeight.w700, height: 30 / 22),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
