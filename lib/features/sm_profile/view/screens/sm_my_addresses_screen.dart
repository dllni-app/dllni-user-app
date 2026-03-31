import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../../data/models/sm_address_list_item.dart';
import '../widgets/rs_address_card.dart';
import '../widgets/rs_personal_details_app_bar.dart';

@AutoRoutePage()
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
            const RsPersonalDetailsAppBar(title: 'عناويني'),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _showSoonMessage('ميزة إضافة عنوان جديد قريباً'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: context.primaryContainer,
                        foregroundColor: context.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText.labelLarge(
                            'إضافة عنوان جديد',
                            color: context.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: context.onPrimaryContainer,
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: context.primaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._addresses.map((item) {
                      final isDefault = _defaultAddressId == item.id;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 12),
                        child: RsAddressCard(
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
