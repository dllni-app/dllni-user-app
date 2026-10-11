# V7 Customer UI: Design-to-code audit

Pen source: alnadha-customer-v7.pen. This is a route/state inventory; it is NOT visual golden verification.
Built/refactored: cleaning order detail state presentation, multi-session overview, SOS flow, booking widgets, account header/cards, order cards/navigation.
Preserved: BLoC, API, price, lifecycle, booking verification and worker assignment actions.

## Pen states
| ID | Pen label | Flutter area (lib/) | Verified pixel fidelity |
|---|---|---|---|
| HOME-01 | الرئيسية | features/home/view/screens/home_screen.dart | Pending device golden |
| CLN-DISC-01 | اكتشاف خدمة التنظيف | features/cl_main/view/screens/cl_main_screen.dart | Pending device golden |
| ORD-LIST-01 | طلباتي | features/orders/view/widgets/orders_list_tab.dart | Pending device golden |
| ORD-DETAIL-01 | تفاصيل الطلب | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| CLN-BOOK-20 | مراجعة الحجز | features/cl_main/view/screens | Pending device golden |
| SOS-01 | المساعدة والسلامة | features/orders/view/screens/cleaning_order_sos_screen.dart | Pending device golden |
| ACC-01 | حسابي | features/profile/view/screens/profile_screen.dart | Pending device golden |
| CLN-BOOK-01 | نوع العقار | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-02 | الغرف والحمامات | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-08 | الموعد والوقت | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-16 | تفضيل العاملة | features/cl_main/view/screens | Pending device golden |
| ORD-DETAIL-02 | بانتظار التأكيد | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-08 | التحقق من رمز العاملة | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-12 | مراجعة إنجاز الطلب | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| HOME-02 | الرئيسية — بحساب وعنوان | features/home/view/screens/home_screen.dart | Pending device golden |
| HOME-03 | الرئيسية — طلب نشط | features/home/view/screens/home_screen.dart | Pending device golden |
| HOME-04 | الرئيسية — طلبات متعددة | features/home/view/screens/home_screen.dart | Pending device golden |
| HOME-05 | الرئيسية — بدون عنوان | features/home/view/screens/home_screen.dart | Pending device golden |
| HOME-06 | الرئيسية — الإشعارات | features/home/view/screens/home_screen.dart | Pending device golden |
| HOME-07 | الرئيسية — البحث | features/home/view/screens/home_screen.dart | Pending device golden |
| NAV-01 | التنقل الأساسي | features/main | Pending device golden |
| CLN-DISC-02 | مقارنة أنواع التنظيف | features/cl_main/view/screens/cl_main_screen.dart | Pending device golden |
| CLN-DISC-03 | خدمات وإضافات | features/cl_main/view/screens/cl_main_screen.dart | Pending device golden |
| CLN-DISC-04 | عاملة سابقة | features/cl_main/view/screens/cl_main_screen.dart | Pending device golden |
| CLN-DISC-05 | تنظيف عاجل | features/cl_main/view/screens/cl_main_screen.dart | Pending device golden |
| CLN-DISC-06 | تنظيف مرن أو متكرر | features/cl_main/view/screens/cl_main_screen.dart | Pending device golden |
| CLN-BOOK-03 | تفاصيل أحجام الغرف | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-04 | مستوى التنظيف | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-05 | المهام الإضافية | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-06 | عنوان الخدمة | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-07 | إضافة عنوان | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-09 | تكرار الحجز | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-10 | أيام التكرار | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-11 | مواعيد عدة أيام | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-12 | تفاصيل المناسبة | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-13 | مساعدة المناسبات | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-14 | طلب عاجل | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-15 | فترة زمنية مرنة | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-17 | اختيار عاملة سابقة | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-18 | عدد العاملات | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-19 | تفضيلات السلامة | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-21 | تغيّر السعر | features/cl_main/view/screens | Pending device golden |
| CLN-BOOK-22 | تم إرسال الطلب | features/cl_main/view/screens | Pending device golden |
| ORD-LIST-02 | الطلبات النشطة | features/orders/view/widgets/orders_list_tab.dart | Pending device golden |
| ORD-LIST-03 | سجل الطلبات | features/orders/view/widgets/orders_list_tab.dart | Pending device golden |
| ORD-LIST-04 | الطلبات الملغاة | features/orders/view/widgets/orders_list_tab.dart | Pending device golden |
| ORD-LIST-05 | طلبات متكررة | features/orders/view/widgets/orders_list_tab.dart | Pending device golden |
| ORD-LIST-06 | لا توجد طلبات | features/orders/view/widgets/orders_list_tab.dart | Pending device golden |
| ORD-LIST-07 | تعذر تحميل الطلبات | features/orders/view/widgets/orders_list_tab.dart | Pending device golden |
| ORD-DETAIL-03 | قبول جزئي للفريق | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-04 | قرار المهام في الساعة الأخيرة | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-05 | تأكيد إعادة توزيع المهام | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-06 | تفاصيل العاملة المقبولة | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-07 | العاملة في الطريق | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-09 | رمز البدء غير صحيح | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-10 | بانتظار بدء العاملة | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-11 | الخدمة قيد التنفيذ | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-13 | الاعتراض على الإتمام | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-14 | طلب تمديد الوقت | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-15 | بانتظار رد العاملة | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-16 | اكتملت الخدمة | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-17 | تقييم العاملة | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-18 | تأكيد إلغاء الطلب | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-19 | أُلغي لعدم توفر عاملة | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-20 | الحجز متعدد الجلسات | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-21 | تفاصيل جلسة متكررة | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| ORD-DETAIL-22 | جلسة بوقت مرن | features/orders/view/screens/cleaning_order_details_screen.dart | Pending device golden |
| SOS-02 | نوع الحالة الطارئة | features/orders/view/screens/cleaning_order_sos_screen.dart | Pending device golden |
| SOS-03 | وصف البلاغ | features/orders/view/screens/cleaning_order_sos_screen.dart | Pending device golden |
| SOS-04 | جاري إرسال البلاغ | features/orders/view/screens/cleaning_order_sos_screen.dart | Pending device golden |
| SOS-05 | تم تسجيل البلاغ | features/orders/view/screens/cleaning_order_sos_screen.dart | Pending device golden |
| SOS-06 | تمت الاستجابة للبلاغ | features/orders/view/screens/cleaning_order_sos_screen.dart | Pending device golden |
| SOS-07 | شكوى خدمة عادية | features/orders/view/screens/cleaning_order_sos_screen.dart | Pending device golden |
| SOS-08 | متابعة الشكوى | features/orders/view/screens/cleaning_order_sos_screen.dart | Pending device golden |
| ACC-02 | الحساب للضيف | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-03 | تعديل المعلومات الشخصية | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-04 | عناويني | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-05 | إضافة أو تعديل عنوان | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-06 | إدارة عنوان | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-07 | الإشعارات | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-08 | تفضيلات الإشعارات | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-09 | القسائم | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-10 | قوائم التسوق | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-11 | ميزات المشاركة | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-12 | مركز المساعدة | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-13 | الشروط والخصوصية | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-14 | تأكيد تسجيل الخروج | features/profile/view/screens/profile_screen.dart | Pending device golden |
| ACC-15 | حذف الحساب | features/profile/view/screens/profile_screen.dart | Pending device golden |
| STATE-01 | حالة التحميل | core/widgets/v7_spot_state.dart | Pending device golden |
| STATE-02 | حالات عدم وجود بيانات | core/widgets/v7_spot_state.dart | Pending device golden |
| STATE-03 | تعذر الاتصال | core/widgets/v7_spot_state.dart | Pending device golden |
| STATE-04 | تسجيل الدخول مطلوب | core/widgets/v7_spot_state.dart | Pending device golden |
| STATE-05 | التحقق من المدخلات | core/widgets/v7_spot_state.dart | Pending device golden |
| STATE-06 | منع الإرسال المكرر | core/widgets/v7_spot_state.dart | Pending device golden |
| STATE-07 | شاشة صغيرة ونص كبير | core/widgets/v7_spot_state.dart | Pending device golden |
| STATE-08 | الجهاز اللوحي ولوحة المفاتيح | core/widgets/v7_spot_state.dart | Pending device golden |

## Unclosed acceptance
- 96 individual Pen state screenshots have not been golden-compared with Flutter.
- Account subpages, specialized cleaning controls and multi-day session actions need per-screen visual review.
- Do not create real orders for QA. Use fixture data for status transitions.
- No confirmed backend API change required solely for the visual components.

## Implementation outcome of this iteration
Directly rebuilt:
- Cleaning order detail main page, state-aware status hero, service location/date, real worker identity, validated quote, customer next action, cancellation visibility and SOS entry.
- Multi-session order overview and each session panel, with server-authorized session actions retained.
- Cleaning order list card with normal/urgent matching statuses, existing navigation and rescheduling callback.
- Worker team accepted entries; previously empty room-assignment UI now displays rooms and delegates edits to the original API callback; last-hour assignment decision restyled with original server guards.
- SOS complaint/emergency staged form and the submitted/acknowledged state presentation.
- Occasion booking progressively disclosed across three stages; booking date/gender/section widgets replaced with new V7 controls.
- Customer account top bar, profile summary, menu rows and section titles.
- Shared cart/orders selector and service-aware order header copy.
Tests used: 51 widget and business-state checks across order widgets and cleaning booking; 10 specific sensitive-action/room tests (overlap possible). Static analyzer of changed Dart screens reported no compile errors, though warning/info lint items remain.
Backend: no API changes or Laravel modifications were needed for this component-level refactor.
Known limits: no individual golden comparison of all 96 design states; not every linked account/booking/detail subpage has been independently rebuilt. This file deliberately does not mark them as fully accepted.

## Account subpages follow-up (2026-10-11)
- Rebuilt `AddressCard` with 48dp actions, selected/default label and choose mode; original address callbacks preserved.
- Rebuilt `NotificationFeedItem` retaining notification category, unread state and rejected time-extension worker response.
- Rebuilt `PlatformCouponCard` (real code, discounts, expiration/eligibility, copy action).
- Rebuilt shopping list cards, compact account page header, and navigation to list details/new list.
- Rebuilt `NumberedSectionCard` and `FilledTextField` visual presentation across address/personal details forms; removed technical raw latitude/longitude display in add address in favor of verified map-selection confirmation.
- Account widget regression: **12 passed** (both existing and new checks).
- No authentication, coupon application, orders or profile persistence API logic was modified.
- Pending strict V7 acceptance: individual golden comparison for 15 account Pen boards and functional fixtures for the add-address map, notification preferences, help center and destructive account actions. The currently connected phone yielded a black screen screenshot (sleep/locked), so no pixel-perfect QA is claimed.

## Order detail / SOS / notifications follow-up (2026-10-11)
- Added dedicated `V7OrderLifecyclePanel` aligned to Pen order-history structure: only actual lifecycle status is shown as current/completed, with no invented worker acceptance, timestamps, ETA or dispatch-radius information. Cancelled orders show cancellation rather than fictitious work stages.
- Added `V7OrderServicesPanel` listing API service/addon line-items or actual property room-counts; no invented task rows.
- Cleaning order-details now includes timeline and requested tasks between status hero and booking details.
- Emergency SOS location attachment is now opt-in (off by default). It never requests current location unless the user enables the switch; SOS sending still works without location; an urgent safety disclaimer directs users to local emergency services for immediate danger.
- Rebuilt notifications screen header, V7 category filter strip, and card spacing. Notification items without a parseable timestamp are no longer silently omitted; they appear in the older bucket.
- New test coverage for progress/task states, location opt-in, notification filters. Broad order/account/booking widget regression: **65 tests passed**.
- Connected Windows machine is online; phone was absent from ADB device list when this follow-up was checked. Android installation and full side-by-side phone visual verification remain pending.
- **Not acceptance of all 96 Pen states**: remaining individual route-state screenshot checks and unconverted specialized forms require separate signoff.
