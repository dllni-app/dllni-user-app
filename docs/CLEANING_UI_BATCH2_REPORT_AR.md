# تقرير الدفعة الثانية — إعادة تصميم تدفق التنظيفات
التاريخ: 2026-10-10  
المشروع: `dllni-user-app`  
الفرع: `dev`  
المرجع: الصورة المعتمدة لنظام التصميم + `designs/user-app-main-redesign/dllni-user-main-booking-redesign-v3.pen`.

## الهدف
تطبيق الأساس البصري الموحد على خطوات التنظيفات الحقيقية من دون تغيير واجهات API أو صياغة Payload أو BLoC أو قواعد التسعير أو إدارة العمال.

## المكونات التي تم تنفيذها

| المسار النسبي ضمن lib/features/cl_main/view/widgets | التغيير |
|---|---|
| cl_main_continue_button_widget.dart | زر المتابعة الأساسي كحلي، ارتفاع 52 وحواف 16 |
| cl_service_bottom_actions_widget.dart | إرسال الطلب كحلي وتراجع Outline، الحفاظ على callbacks |
| cl_main_service_tabs_widget.dart | إلغاء Gradient وفرض اختيار نشط كحلي وحجم لمس >= 48، الحفاظ على keys والفهارس |
| cl_cleaning_type_option_card_widget.dart | Radio/بطاقة موحدة بحالة محددة واضحة وإمكانية وصول |
| cl_option_tile_widget.dart | خيار إضافي كخانة اختيار بخلفية فيروزية فاتحة وحالة قابلة للنقر |
| cl_counter_row_widget.dart | عدادات الغرف بأزرار 44 وأيقونات داكنة على سطح فيروزي فاتح |
| cl_service_worker_count_selector_widget.dart | عداد العمال (1..maxCount) والتعطيل حسب الحدود مع واجهة موحدة |
| cl_service_assignment_mode_section_widget.dart | بطاقات اختيار عامل/فريق بحدود كحلية؛ ميزة recommended فيروزية |
| cl_service_section_card_widget.dart | حواف 18، عناوين كحلية، حدود وPadding موحدة |
| cl_home_description_title_card_widget.dart | اعتماد مكون ClServiceSectionCardWidget المشترك بدل كارت مختلف |
| cl_service_gradient_info_card_widget.dart | إزالة التدرج ضعيف التباين؛ معلومات من Backend على سطح فيروزي فاتح |
| cl_cleaning_services_selector_widget.dart | تحسين Chips والاختيار والخطأ وزر إضافة خدمة |
| cl_property_type_card_widget.dart | حواف وبطاقة وصف ذات تباين أفضل؛ التنقل كما هو |
| cl_service_schedule_section_widget.dart | «تغيير اليوم» ثانوي فيروزي بكتابة داكنة |
| cl_service_day_preview_card_widget.dart | توحيد عرض التاريخ وألوان التقويم |
| home_details_app_bar.dart | عنوان كحلي وترويسة متسقة مع اللون المساعد للتنظيف |
| ../screens/cl_main_home_description_screen.dart | تحسين صياغة عنوان خطوة تحديد عدد الغرف فقط دون تغيير الإجراءات |
| cl_service_coupon_section_widget.dart | زر تطبيق كحلي، الحفاظ على حالات النجاح والفشل |
| cl_service_order_summary_section_widget.dart | العنوان والإجمالي كحلي وتوحيد الحدود، دون تعديل الحساب |
| cl_service_time_picker_field_widget.dart | حدود الحقل من Tokens |
| cl_selectable_menu_field_widget.dart | حواف 16، خلفية بيضاء وحدود محايدة |

## الاختبارات التي تم تنفيذها
- `test/features/cl_main/view/widgets/cleaning_foundations_v2_test.dart`: **7 حالات اختبار ناجحة**:
  - تبويبات أنواع التنظيف وإبقاء Callback محدد الفهرس.
  - زر المتابعة في حالتي التفعيل والتعطيل.
  - إرسال الطلب والتراجع.
  - نوع التنظيف.
  - خيار إضافي.
  - عداد الغرف.
  - حدود عدد العمال.
- `git diff --check` تم تشغيله لتفادي تغييرات whitespace غير السليمة.
- `flutter analyze --no-pub` للملفات المستهدفة (19 ملفاً): **No issues found**.
- `test/features/cl_main/view/widgets/cleaning_foundations_responsive_test.dart`: **اختبار ناجح** لعرض 320dp واتجاه RTL ودون Overflow في مكونات التبويب/اختيار العامل/الإجراءات.
- مجموعة اختبارات الانحدار القائمة (الكوبون، ملخص السعر، الشاشة الرئيسية، نموذج توزيع الغرف): **8 ناجحة، 1 متجاوز/Skipped**، دون إخفاقات. اختبار التخطي كان ضمن `CleaningProgressiveRoomState preserves room choices when counts grow and shrink` ويحتاج مراجعة سبب التجاوز لاحقاً.
- استُبعدت تغييرات تنسيق عرضية في `app_pickers.dart` و`cl_cleaning_extras_section_widget.dart` حتى تبقى الدفعة مركّزة على واجهة العرض.

## ثوابت السلوك
- أسماء `ClMainServiceTabsWidget.cleaningIndex / occasionsIndex / hourlyIndex` ومفاتيح الاختبارات لم تتغير.
- تبقى بيانات الحسابات التقديرية وخصومات الكوبون والسعر النهائي كما تأتي من الخدمات القائمة.
- أبقيت معاملات `onTap / onChanged / onPressed` كما هي.
- لا تعديلات على backend migrations/models/routes/controllers أو Realtime وDeep Linking.

## عناصر الدفعة الثالثة / QA المتبقية
- فحص تشغيل شاشات التنظيف الرئيسية ومقارنة Screenshots فعلياً مع Pen V3 (390x844 و320/430).
- فحص حالات المساحات والنوع العميق وحجز المناسبات والوقت المفتوح والتكرار والجلسات.
- فحص تفصيلي لبطاقات العمال السابقين وتوزيع الغرف على الفريق.
- مراجعة Timeline التتبع والـ OTP والتمديد وإلغاء الطلب ومواجهة SOS.
- مراجعة شاشات المطاعم والسوبرماركت بالكامل تحت Design Tokens الجديدة بعد التعديلات التأسيسية.
- اختبار E2E كاملاً مع Backend وRealtime، وتأكيد نتائج Golden Tests على الأجهزة.

## التوصية
تُعتمد هذه الدفعة كبنية موحدة لعناصر الحجز الأساسية؛ لا تعتبر إعادة التصميم الكامل للشاشات أو اختباراً نهائياً للتكامل. لا تُدمج إلى Production قبل الفحص البصري وE2E.
