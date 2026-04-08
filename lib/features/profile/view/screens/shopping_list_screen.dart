import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

@AutoRoutePage(path: "/shopping_list")
class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          const _ShoppingListHeader(
            title: "قائمة التسوق الذكي",
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 4,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, index) => GestureDetector(
                onTap: () {
                  context.pushRoute("/shopping_list_details");
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Color(0x0D000000),
                      ),
                    ],
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0x2B22C55E),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
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
                              ? "قائمة تسوق المنزل"
                              : index == 1
                                  ? "قائمة تسوق العمل"
                                  : index == 2
                                      ? "قائمة تسوق العمل"
                                      : "قائمة تسوق وجبات صحية",
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 24 / 16,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: FaIcon(
                          FontAwesomeIcons.penToSquare,
                          size: 17,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        color: const Color(0xFFF3F4F6),
        child: GestureDetector(
          onTap: () {
            debugPrint("إضافة قائمة تسوق جديدة");
          },
          child: Container(
            padding: const EdgeInsets.only(top: 14, bottom: 13),
            decoration: const BoxDecoration(
              color: Color(0xFFFF7A00),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: AppText(
              "إضافة قائمة تسوق جديدة",
              style: TextStyle(
                color: Color(0xFFFFEEFF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 16 / 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShoppingListHeader extends StatelessWidget {
  const _ShoppingListHeader({required this.title});

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
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFDDF3E3),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(FontAwesomeIcons.basketShopping, size: 20, color: Color(0xFF43B654)),
          ),
        ],
      ),
    );
  }
}
