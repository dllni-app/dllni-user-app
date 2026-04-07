import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../data/models/sm_address_list_item.dart';
import '../widgets/sm_address_card.dart';

@AutoRoutePage(path: "/sm_my_addresses")
class SmMyAddressesScreen extends StatefulWidget {
  const SmMyAddressesScreen({super.key});

  @override
  State<SmMyAddressesScreen> createState() => _SmMyAddressesScreenState();
}

class _SmMyAddressesScreenState extends State<SmMyAddressesScreen> {
  static const List<SmAddressListItem> _addresses = [
    SmAddressListItem(
      id: 'home',
      label: 'المنزل',
      line1: 'حلب - الفرقان - شارع الجامعة، بناء السعادة، الطابق الرابع',
      landmark: 'بجانب صيدلية الشفاء',
      type: SmAddressType.home,
      isDefault: true,
    ),
    SmAddressListItem(
      id: 'work',
      label: 'العمل',
      line1: 'حلب - الموكامبو - شارع النيل، مبنى الشركة التجارية',
      type: SmAddressType.work,
    ),
    SmAddressListItem(
      id: 'family',
      label: 'بيت العائلة',
      line1: 'حلب - المحافظة - شارع الأندلس، فيلا رقم 5',
      landmark: 'الباب الأخضر الكبير',
      type: SmAddressType.family,
    ),
  ];

  late String _defaultAddressId = _addresses
      .firstWhere((item) => item.isDefault, orElse: () => _addresses.first)
      .id;

  void _showSoonMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const AppSimpleAppBar2(
              title: "عناويني",
              arrowBackType: ArrowBackType.cupertino,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._addresses.map((item) {
                      final isDefault = _defaultAddressId == item.id;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 12),
                        child: SmAddressCard(
                          item: item,
                          isDefault: isDefault,
                          onSetDefault: isDefault
                              ? null
                              : () {
                                  setState(() => _defaultAddressId = item.id);
                                },
                          onEdit: () =>
                              _showSoonMessage('تعديل العنوان غير متاح حالياً'),
                          onDelete: () =>
                              _showSoonMessage('حذف العنوان غير متاح حالياً'),
                        ),
                      );
                    }),
                    SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        context.pushRoute("/sm_address_details");
                      },
                      child: Container(
                        width: context.width,
                        padding: EdgeInsets.only(top: 11, bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: AppText(
                          "إضافة عنوان جديد",
                          style: TextStyle(
                            color: Color(0xFFFFEEFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 22 / 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
