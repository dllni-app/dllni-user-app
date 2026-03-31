import 'package:flutter/material.dart';

import '../../../../core/utils/app_images.dart';
import '../widgets/order_card.dart';
import '../widgets/orders_simple_app_bar.dart';

class SmOrdersScreen extends StatelessWidget {
  const SmOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          OrdersSimpleAppBar(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(24),
              itemCount: orderList.length,
              itemBuilder: (context, index) =>
                  OrderCard(order: orderList[index]),
              separatorBuilder: (context, index) => SizedBox(height: 16),
            ),
          ),
        ],
      ),
    );
  }
}

List<OrderItemData> orderList = [
  OrderItemData(
    id: '145687_755',
    imageUrl: AppImages.store,
    name: 'سوبر ماركت النور',
    quantity: 14,
    price: 79.99,
    date: 'فبراير 24 2026 2:31 م',
    isPaid: true,
  ),
  OrderItemData(
    id: '145687_756',
    imageUrl: AppImages.store,
    name: 'صيدلية الشفاء',
    quantity: 3,
    price: 120.50,
    date: 'مارس 10 2026 10:15 ص',
    isPaid: true,
  ),
  OrderItemData(
    id: '145687_757',
    imageUrl: AppImages.store,
    name: 'مخبز البركة',
    quantity: 20,
    price: 15.00,
    date: 'مارس 15 2026 08:45 ص',
    isPaid: false,
  ),
  OrderItemData(
    id: '145687_758',
    imageUrl: AppImages.store,
    name: 'عالم التقنية',
    quantity: 1,
    price: 2500.00,
    date: 'مارس 28 2026 11:20 م',
    isPaid: true,
  ),
  OrderItemData(
    id: '145687_759',
    imageUrl: AppImages.store,
    name: 'مطعم الياسمين',
    quantity: 5,
    price: 340.75,
    date: 'مارس 30 2026 01:00 م',
    isPaid: false,
  ),
];
