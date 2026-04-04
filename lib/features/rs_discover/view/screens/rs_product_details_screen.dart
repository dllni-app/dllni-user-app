import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/fetch_restaurant_product_details_model.dart';
import '../../domain/usecases/fetch_restaurant_product_details_use_case.dart';
import '../models/product_preview_data.dart';

class ProductDetailsScreenParams {
  final ProductPreviewData product;

  ProductDetailsScreenParams({required this.product});
}

@AutoRoutePage(path: "/product")
class SmProductDetailsScreen extends StatefulWidget {
  const SmProductDetailsScreen({super.key, required this.params});

  final ProductDetailsScreenParams params;

  @override
  State<SmProductDetailsScreen> createState() => _SmProductDetailsScreenState();
}

class _SmProductDetailsScreenState extends State<SmProductDetailsScreen> {
  final TextEditingController notesController = TextEditingController();
  FetchRestaurantProductDetailsModel? _details;
  bool _isLoadingDetails = false;
  int _quantity = 1;
  final Map<int, Set<int>> _selectedModifierIdsByGroup = {};

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetails() async {
    if (widget.params.product.productId <= 0) return;
    setState(() {
      _isLoadingDetails = true;
    });
    final useCase = getIt<FetchRestaurantProductDetailsUseCase>();
    final response = await useCase(
      FetchRestaurantProductDetailsParams(
        productId: widget.params.product.productId,
      ),
    );
    response.fold((_) {}, (value) {
      _details = value;
    });
    if (mounted) {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  String get _name {
    return _details?.product?.name?.trim().isNotEmpty == true
        ? _details!.product!.name!.trim()
        : widget.params.product.name;
  }

  String get _restaurantName {
    final preview = widget.params.product.restaurantName.trim();
    return preview.isNotEmpty ? preview : 'مطعم';
  }

  String get _description {
    return _details?.product?.description?.trim().isNotEmpty == true
        ? _details!.product!.description!.trim()
        : widget.params.product.description;
  }

  String? get _imageUrl {
    final primary = _details?.product?.primaryImage?.trim();
    if (primary != null && primary.isNotEmpty) return primary;
    final preview = widget.params.product.imageUrl?.trim();
    if (preview != null && preview.isNotEmpty) return preview;
    return null;
  }

  num? get _displayPrice {
    return _details?.product?.discountedPrice ??
        _details?.product?.price ??
        widget.params.product.displayPrice;
  }

  num? get _oldPrice {
    final detailsProduct = _details?.product;
    if (detailsProduct?.discountedPrice != null &&
        detailsProduct?.price != null) {
      return detailsProduct!.price;
    }
    return widget.params.product.originalPrice;
  }

  String _priceText(num? value) {
    if (value == null) return '-';
    final clean = value % 1 == 0 ? value.toInt().toString() : value.toString();
    final currency = (widget.params.product.currency ?? '').trim();
    return currency.isEmpty ? clean : '$clean $currency';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: AppText(
          _name,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 24 / 17,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _ActionButton(
            icon: Icons.arrow_back,
            onTap: () => context.maybePop(),
          ),
        ),
        actions: [
          _ActionButton(icon: Icons.favorite_outline, onTap: () {}),
          SizedBox(width: 8),
          _ActionButton(icon: Icons.share, onTap: () {}),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 350,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _imageUrl != null
                          ? AppImage.network(
                              _imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: _productPlaceholder(),
                            )
                          : _productPlaceholder(),
                    ),
                    Positioned(
                      top: 20,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _Badge(
                            title: "الأكثر طلباً",
                            color: Color(0xFFEF4444),
                          ),
                          SizedBox(height: 8),
                          _Badge(title: "عرض خاص", color: Color(0xFF22C55E)),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 18,
                      left: 16,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: context.onPrimary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 4),
                                blurRadius: 12,
                                color: Color(0x1A000000),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.fullscreen,
                            size: 18,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: context.onPrimary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    AppText(
                      _name,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 36 / 2,
                        fontWeight: FontWeight.w700,
                        height: 30 / 18,
                      ),
                    ),
                    SizedBox(height: 6),
                    AppText(
                      _restaurantName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 22 / 14,
                      ),
                    ),
                    if (_description.isNotEmpty) ...[
                      SizedBox(height: 8),
                      AppText(
                        _description,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 20 / 13,
                        ),
                      ),
                    ],
                    SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsetsDirectional.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xffFEFCE8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.solidStar,
                                size: 13,
                                color: Color(0xFFFBBF24),
                              ),
                              AppText(
                                "4.9",
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 20 / 14,
                                ),
                              ),
                              SizedBox(width: 6),
                              AppText(
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 20 / 13,
                                ),
                                "(320 تقييم)",
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsetsDirectional.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xffF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.fire,
                                size: 13,
                                color: context.primaryContainer,
                              ),
                              SizedBox(width: 6),
                              AppText(
                                "450 مرة طلب",
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 20 / 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          _priceText(_displayPrice),
                          style: TextStyle(
                            color: Color(0xFF16A34A),
                            fontSize: 44 / 2,
                            fontWeight: FontWeight.w700,
                            height: 30 / 22,
                          ),
                        ),
                        if (_oldPrice != null)
                          AppText(
                            _priceText(_oldPrice),
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 24 / 2,
                              fontWeight: FontWeight.w500,
                              height: 20 / 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                color: context.onPrimary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "إضافات اختيارية",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 32 / 2,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    AppText(
                      "اختر ما يناسبك",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 16 / 12,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_isLoadingDetails)
                      const Center(child: CircularProgressIndicator())
                    else if ((_details?.modifierGroups ??
                            const <RestaurantProductDetailsModifierGroup>[])
                        .isEmpty)
                      AppText(
                        "لا توجد إضافات متاحة لهذا المنتج",
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      ...(_details?.modifierGroups ??
                              const <RestaurantProductDetailsModifierGroup>[])
                          .map((group) {
                            final selectedIds = _selectedForGroup(group);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ModifierGroupCard(
                                group: group,
                                selectedModifierIds: selectedIds,
                                onModifierTap: (modifierId) {
                                  _toggleModifier(
                                    group: group,
                                    modifierId: modifierId,
                                  );
                                },
                              ),
                            );
                          }),
                  ],
                ),
              ),
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                color: context.onPrimary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "ملاحظات خاصة",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 32 / 2,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    AppText(
                      "أضف اي طلب خاص",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 16 / 12,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      minLines: 2,
                      maxLines: 3,
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 20 / 14,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            "اكتب ملاحظة خاصة بالطلب (اختياري)\nمثال: بدون بصل - مستوى حار جدا",
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 20 / 13,
                        ),
                        contentPadding: EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuickNoteChip(
                          label: "بدون بصل",
                          onTap: () => _appendQuickNote("بدون بصل"),
                        ),
                        _QuickNoteChip(
                          label: "بدون طماطم",
                          onTap: () => _appendQuickNote("بدون طماطم"),
                        ),
                        _QuickNoteChip(
                          label: "مستوى حار جدا",
                          onTap: () => _appendQuickNote("مستوى حار جدا"),
                        ),
                        _QuickNoteChip(
                          label: "صوص إضافي",
                          onTap: () => _appendQuickNote("صوص إضافي"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _ProductBottomBar(
        quantity: _quantity,
        isSubmitting: false,
        onDecrease: () {
          if (_quantity == 1) return;
          setState(() {
            _quantity -= 1;
          });
        },
        onIncrease: () {
          setState(() {
            _quantity += 1;
          });
        },
        onAddPressed: () async {

        },
      ),
    );
  }

  void _appendQuickNote(String note) {
    final current = notesController.text.trim();
    final text = current.isEmpty ? note : '$current - $note';
    notesController.text = text;
    notesController.selection = TextSelection.collapsed(
      offset: notesController.text.length,
    );
  }

  Set<int> _selectedForGroup(RestaurantProductDetailsModifierGroup group) {
    final id = group.id;
    if (id == null) return <int>{};
    return _selectedModifierIdsByGroup[id] ?? <int>{};
  }

  void _toggleModifier({
    required RestaurantProductDetailsModifierGroup group,
    required int modifierId,
  }) {
    final groupId = group.id;
    if (groupId == null) return;
    final current = {...(_selectedModifierIdsByGroup[groupId] ?? <int>{})};
    final has = current.contains(modifierId);
    if (group.maxSelections <= 1) {
      current
        ..clear()
        ..add(modifierId);
      if (has) {
        current.clear();
      }
    } else {
      if (has) {
        current.remove(modifierId);
      } else {
        if (group.maxSelections > 0 && current.length >= group.maxSelections) {
          return;
        }
        current.add(modifierId);
      }
    }
    setState(() {
      _selectedModifierIdsByGroup[groupId] = current;
    });
  }
}

Widget _productPlaceholder() {
  return Container(
    color: const Color(0xFFF5F5F5),
    alignment: Alignment.center,
    child: const Icon(Icons.image_outlined, size: 56, color: Color(0xFF9CA3AF)),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsetsDirectional.all(10),
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Icon(icon, size: 20, color: Color(0xFF1F2937)),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 8,
            color: Color(0x1A000000),
          ),
        ],
      ),
      child: AppText(
        title,
        style: TextStyle(
          color: context.onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 16 / 11,
        ),
      ),
    );
  }
}

class _ModifierGroupCard extends StatelessWidget {
  const _ModifierGroupCard({
    required this.group,
    required this.selectedModifierIds,
    required this.onModifierTap,
  });

  final RestaurantProductDetailsModifierGroup group;
  final Set<int> selectedModifierIds;
  final void Function(int modifierId) onModifierTap;

  @override
  Widget build(BuildContext context) {
    final maxText = group.maxSelections > 0
        ? '${group.maxSelections}'
        : 'غير محدد';
    final minText = group.minSelections > 0 ? '${group.minSelections}' : '0';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            group.name ?? 'إضافات',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 20 / 15,
            ),
          ),
          SizedBox(height: 2),
          AppText(
            group.isRequired
                ? 'مطلوب - اختر من $minText إلى $maxText'
                : 'اختياري - حتى $maxText',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 18 / 12,
            ),
          ),
          SizedBox(height: 10),
          ...group.modifiers.map((modifier) {
            final modifierId = modifier.id;
            if (modifierId == null) return const SizedBox.shrink();
            final isSelected = selectedModifierIds.contains(modifierId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => onModifierTap(modifierId),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFFFF7ED) : Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Color(0xFFFF7A00) : Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : (group.maxSelections <= 1
                                  ? Icons.radio_button_unchecked
                                  : Icons.check_box_outline_blank),
                        color: isSelected
                            ? Color(0xFFFF7A00)
                            : Color(0xFF9CA3AF),
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: AppText(
                          modifier.name ?? 'إضافة',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppText(
                        _modifierPriceText(modifier.price),
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String _modifierPriceText(num? price) {
  if (price == null || price == 0) return '+0 ل.س';
  return '+$price ل.س';
}

class _QuickNoteChip extends StatelessWidget {
  const _QuickNoteChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: AppText(
          label,
          style: TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 16 / 12,
          ),
        ),
      ),
    );
  }
}

class _ProductBottomBar extends StatelessWidget {
  const _ProductBottomBar({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAddPressed,
    this.isSubmitting = false,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAddPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.onPrimary,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 30,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CircleCounterButton(
                icon: FontAwesomeIcons.minus,
                color: Color(0xFFF3F4F6),
                iconColor: Color(0xFF6B7280),
                onTap: onDecrease,
              ),
              AppText(
                quantity.toString(),
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 36 / 2,
                  fontWeight: FontWeight.w700,
                  height: 28 / 18,
                ),
              ),
              _CircleCounterButton(
                icon: FontAwesomeIcons.plus,
                color: Color(0xFFFF7A00),
                iconColor: Colors.white,
                onTap: onIncrease,
              ),
            ],
          ),
          SizedBox(height: 12),
          InkWell(
            onTap: isSubmitting ? null : onAddPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Color(0xFFFF7A00),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.cartShopping,
                    size: 13,
                    color: context.onPrimary,
                  ),
                  SizedBox(width: 8),
                  AppText(
                    isSubmitting ? "جاري الإضافة..." : "إضافة إلى السلة",
                    style: TextStyle(
                      color: context.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 24 / 16,
                    ),
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

class _CircleCounterButton extends StatelessWidget {
  const _CircleCounterButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final FaIconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: FaIcon(icon, size: 12, color: iconColor),
      ),
    );
  }
}
