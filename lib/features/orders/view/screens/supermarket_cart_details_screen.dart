import 'package:common_package/common_package.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/widgets/app_app_bars.dart';
import '../../data/models/fetch_supermarket_cart_model.dart';
import '../manager/bloc/orders_bloc.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.storeName,
    required this.weight,
    required this.addons,
    required this.price,
    required this.count,
  });
  final String imageUrl;
  final String name;
  final String storeName;
  final String weight;
  final String addons;
  final num price;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 2,
            color: Color(0x0D000000),
          ),
        ],
      ),
      child: Column(
        spacing: 12,
        children: [
          Row(
            children: [
              AppImage.asset(
                AppImages.products,
                size: 96,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      "لبنة نيو بارك",
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 23 / 18,
                      ),
                    ),
                    Text(
                      "متجر النور",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "الوزن :"),
                          TextSpan(
                            text: " 250 كغ",
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "الإضافات:"),
                          TextSpan(
                            text: " جبنة إضافية، صوص خاص",
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  border: Border.all(color: Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.minus,
                            size: 12,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        "2",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.plus,
                            size: 12,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "450 ل.س",
                style: TextStyle(
                  color: Color(0xFF1A237E),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                ),
              ),
            ],
          ),
          Center(
            child: _TextButtonWithIcon(
              label: "حذف",
              icon: FontAwesomeIcons.trash,
              color: Color(0xFFFF4C51),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class SupermarketCartDetailsArgs {
  final String? storeName;
  final FetchSupermarketCartModelDataItemMerchantGroupsItem? cart;

  SupermarketCartDetailsArgs({this.storeName, this.cart});
}

@AutoRoutePage()
class SupermarketCartDetailsScreen extends StatefulWidget {
  final SupermarketCartDetailsArgs args;
  const SupermarketCartDetailsScreen({super.key, required this.args});

  @override
  State<SupermarketCartDetailsScreen> createState() =>
      _SupermarketCartDetailsScreenState();
}

class _AddAnotherProducts extends StatelessWidget {
  final void Function() onTap;
  const _AddAnotherProducts({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      borderRadius: BorderRadius.all(Radius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: DottedBorder(
          ignoring: false,
          options: RoundedRectDottedBorderOptions(
            radius: Radius.circular(16),
            dashPattern: [12, 6],
            strokeWidth: 2,
            color: Color(0x1F2F2B3D),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.plus,
                  color: Color(0xE52F2B3D),
                  size: 13,
                ),
                SizedBox(width: 4),
                Text(
                  "إضافة منتجات أخرى",
                  style: TextStyle(
                    color: Color(0xE52F2B3D),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CounterChip extends StatefulWidget {
  final int initialCount;
  final void Function(int value) onChanged;
  const _CounterChip({required this.onChanged, this.initialCount = 1});
  @override
  State<_CounterChip> createState() => _CounterChipState();
}

class _CounterChipState extends State<_CounterChip> {
  int counter = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 7.4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 14,
        children: [
          InkWell(
            onTap: () {
              if (counter == 1) return;
              counter--;
              setState(() {});
              widget.onChanged(counter);
            },
            customBorder: CircleBorder(),
            child: FaIcon(
              FontAwesomeIcons.minus,
              color: Colors.black,
              size: 11,
            ),
          ),
          Text(
            counter.toString(),
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 28 / 12,
            ),
          ),
          InkWell(
            onTap: () {
              counter++;
              setState(() {});
              widget.onChanged(counter);
            },
            customBorder: CircleBorder(),
            child: FaIcon(
              FontAwesomeIcons.plus,
              color: AppColors.accent,
              size: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    counter = widget.initialCount;
    super.initState();
  }
}

class _SupermarketCartDetailsScreenState
    extends State<SupermarketCartDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppSimpleAppBar2(
            title: 'سلة ${widget.args.storeName ?? 'غير معروف'}',
          ),
          BlocConsumer<OrdersBloc, OrdersState>(
            listener: (context, state) {},
            buildWhen:(previous, current) => previous.supermarketCartStatus != current.supermarketCartStatus,
            builder: (context, state) {
              // if(state.supermarketCartStatus == BlocStatus.loading) {
              //   return Center(child: CircularProgressIndicator());
              // }
              // else if(state.super)
              return Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (_, _) => ProductCard(
                          imageUrl: '',
                          name: '',
                          storeName: '',
                          weight: '',
                          addons: '',
                          price: 0,
                          count: 0,
                        ),
                        separatorBuilder: (_, _) => SizedBox(height: 16),
                        itemCount: 2,
                      ),
                      SizedBox(height: 20),
                      _AddAnotherProducts(onTap: () {}),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TextButtonWithIcon extends StatelessWidget {
  final String label;
  final FaIconData icon;
  final Color color;
  final void Function()? onTap;
  const _TextButtonWithIcon({
    required this.label,
    required this.icon,
    this.onTap,
    this.color = const Color(0xFF1A237E),
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        splashColor: color.withValues(alpha: .18),
        highlightColor: color.withValues(alpha: .08),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            FaIcon(icon, size: 12, color: color),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 16 / 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// RestaurantCartOrderSummarySection(
//   itemsCount: cart.items.length,
//   subtotal: cart.amounts?.subtotal ?? 0,
//   discount: 0,
//   total: cart.amounts?.total ?? 0,
// ),
// const SizedBox(height: 12),
// RestaurantCartCheckoutFulfillmentButton(
//   onTap: () {
//     if (cartId == null) return;
//     context.read<OrdersBloc>().add(
//       SelectStoreCartEvent(cartId: cartId),
//     );
//     context.pushRoute(
//       '/restaurant-order-fulfillment',
//       arguments: RestaurantOrderFulfillmentArgs(
//         bloc: context.read<OrdersBloc>(),
//         cartId: cartId,
//         section: 'supermarket',
//       ),
//     );
//   },
// ),
