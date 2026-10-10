# المرحلة الثالثة — تقرير مراجعة التنظيفات وربط Android USB

التاريخ: 2026-10-10  
المشروع: `C:\laragon\www\Dllni\dllni-user-app`  
الفرع: `dev`  
الحالة: **تعديلات واجهة تم اختبارها على Flutter Widget Tests؛ مراجعة Android الفعلية تنتظر ظهور الجهاز في ADB**.

## نتائج فحص اتصال الهاتف

- Windows يكتشف **Redmi Note 13 Pro**، كما يظهر `ADB Interface` ضمن USBDevice بحالة OK.
- Android SDK الأصلي في `%LOCALAPPDATA%\Android\Sdk` لا يحتوي على platform-tools أو platforms أو build-tools.
- جرى تنزيل Google Android SDK Platform-Tools **37.0.1** من رابط Google الرسمي عبر `redirector.gvt1.com` إلى:
  `C:\laragon\www\Dllni\.tools\android-sdk\platform-tools`
- `adb.exe devices -l` يعمل لكنه يُرجع قائمة فارغة؛ تجربة `ADB_USB_LEGACY=1` لم تظهر الجهاز.
- `flutter devices` يعرض Windows وChrome وEdge فقط.
- يحتاج الهاتف إلى تفعيل USB debugging، إبقاء الشاشة مفتوحة، اختيار File Transfer والسماح ببصمة هذا الكمبيوتر عند ظهور النافذة.
- لم تُثبّت Android SDK Platform/Build-Tools/Cmdline-Tools الكبيرة؛ يلزم إعدادها قبل بناء APK جديد إذا لم تكن مثبتة في مسار آخر. يُراعى استهلاك موارد اللابتوب.
- APK قديم موجود في `build\app\outputs\flutter-apk\user.apk` لكن تاريخ الملف 2026-07-12؛ **ليس إصدار التصميم الحالي** ولا يصلح للمطابقة النهائية.
- لم تُؤخذ لقطات شاشة من الهاتف ولم يُجر اختبار E2E حقيقي، لذا لا يجوز وصف هذه المراجعة بأنها اعتماد Android نهائي.

## تعديلات UI المنجزة

- `cl_service_worker_room_assignment_widget.dart`: الاختيار النشط كحلي، أزرار العمال مريحة للمس، حالات أخطاء واضحة، الحفاظ على callbacks وخيار التلقائي.
- `cl_service_worker_assignment_summary_widget.dart`: ألوان البطاقات والـ chips مرتبطة بالفيروزي الداكن بدل الأزرق القديم.
- `cl_recurring_schedule_section_widget.dart`: توحيد اختيار الزيارات والألوان والحدود وفق tokens المعتمدة دون تعديل تكرار الجلسات.
- `cl_open_time_sessions_section_widget.dart`: مؤشرات الجلسات وحدودها موحدة؛ الحفاظ على سقف المدة والـ callbacks.
- `cleaning_start_verification_dialog.dart`: عنوان كحلي، حقول التحقق بلون مساعد، زر «ليس الآن» يعيد false ويتيح الخروج، ولا يظهر إلغاء الطلب عند غياب bookingId لتفادي null assertion.
- `cleaning_worker_tracking_map.dart`: تحديث ألوان بيان الحالة فقط؛ ترك polling / realtime / OSRM / markers / endpoints دون تغيير.

## الاختبارات والفحوص

- `flutter analyze --no-pub` على الملفات الستة المعدلة: **No issues found**.
- `flutter test --no-pub` على اختبارات الحجز المتكرر، جلسات الوقت المفتوح، نموذج توزيع الغرف، ومغادرة نافذة رمز التحقق دون رقم حجز: **11/11 passed**.
- `git diff --check`: لا توجد أخطاء whitespace؛ تنبيهات EOL بين LF وCRLF فقط.
- التغييرات محلية على `dev`، بدون Commit/Push وبدون تعديل Backend.

## قبل اختبار Android على الهاتف

1. تفعيل **USB debugging** في Developer Options على Redmi Note 13 Pro.
2. فتح الشاشة وقبول **Allow USB debugging**، واختيار **File Transfer**.
3. إعادة تشغيل `adb devices -l` باستخدام النسخة الموجودة داخل مجلد المشروع والتأكد من ظهور `device` وليس `unauthorized`.
4. تجهيز Android SDK build-tools/platform/cmdline-tools داخل المشروع بعد مراجعة الموارد والمساحة إذا لزم بناء APK جديد.
5. تشغيل نسخة Debug من `dev`، ومقارنة الشاشات المعتمدة مع Pen V3 على جهاز 390dp تقريباً، ثم التتبع والحجز المتكرر والمناسبات والغرف والكوبون وإجراء لقطة شاشة / E2E.

## القيود

حظر تغيير API endpoints وBLoC contracts والمنطق التجاري والسعر وتوزيع العامل الخادمي. تُستخدم هذه الدفعة كنقطة تقدم، وليست تصريحاً بجاهزية إطلاق التطبيق.

## تحديث USB بعد تأكيد المستخدم — 2026-10-10

- أكد المستخدم تفعيل إعدادات تصحيح USB.
- يتعرف Windows على Redmi Note 13 Pro، وعلى ADB Interface بحالة CM_PROB_NONE.
- الواجهة تستخدم WINUSB / winusb.inf (Microsoft) ورقم USB: VID_2717 PID_FF48 MI_01.
- ADB 37.0.1 يشتغل لكن adb devices -l فارغ بعد تجربة ADB_LIBUSB=1 و ADB_USB_LEGACY=1.
- لا يظهر DeviceInterfaceGUID لتطبيق ADB على هذه الواجهة ضمن التسجيل النشط. الاحتمال الأقوى: تعريف USB العام لا يسجل واجهة اكتشاف ADB المطلوبة؛ يلزم تحقق من تعريف مناسب قبل تعديل Windows.
- لم تُغيّر تعريفات Windows أو Registry التزاماً بنطاق المشروع.
- SDK Android المحلي يفتقد platforms و build-tools و Java غير متاحة في PATH. APK الموجود قديم وغير صالح لاختبار تغييرات اليوم.
- تم تحديث ألوان cleaning_lifecycle_timeline_widget.dart إلى Palette المعتمد مع الحفاظ على مراحل الطلب.
- اختبارات cleaning_lifecycle_timeline_design_test.dart: 3/3 passed.
- اختبار Android المباشر متوقف على حل تعريف ADB وإعداد أدوات البناء اللازمة.

## تحديث إصلاح Android USB وإعداد البناء — 2026-10-10

- تأكد وجود Redmi Note 13 Pro (23117RA68G) وADB Interface على Windows؛ الأول كان يستخدم WinUSB العام دون GUID.
- بإذن المستخدم، أضيفت قيمة `DeviceInterfaceGUIDs` الخاصة بـ Android ADB فقط إلى Device Parameters للواجهة المطابقة لـ USB VID_2717 PID_FF48 MI_01، بعد حفظ ملف Registry احتياطي.
- أعيد تشغيل واجهة USB الخاصة بالهاتف وحدها بواسطة pnputil؛ الهاتف ظهر في `adb devices -l` بحالة `device` وفي Flutter كـ Android 16 API 36.
- مسار النسخ الاحتياطية والتراجع: `C:\laragon\www\Dllni\.tools\adb-driver-backup`، ولا حاجة لإعادة تثبيت تعريفات أخرى.
- ثبتت أدوات Google الرسمية Platform-Tools 37.0.1 وCommand-line Tools وAndroid Platform 36 وBuild-Tools 36.0.0 داخل `C:\laragon\www\Dllni\.tools\android-sdk`، مع تحقق hash من ملفات ZIP.
- غيّر `android/local.properties` المحلي (غير المتعقب Git) لتشير `sdk.dir` إلى SDK داخل مساحة العمل، مع الاحتفاظ بنسخة احتياطية.
- أول محاولة `flutter build apk --debug --no-pub` وصلت Gradle لكنها توقفت بسبب غياب NDK المطلوب `27.0.12077973` وصعوبة تحميل Manifest من dl.google.com؛ لم يظهر خطأ Flutter/Dart متعلق بالتصميم.
- بدأ تنزيل NDK r27 الرسمي مع التحقق من SHA1 ونظام استخراج موفّر للموارد، دون تشغيل Docker أو محاكي Android.
- فحص الهاتف: `1080x2400`، density `440`، Android API `36`؛ التطبيق الحالي `com.alnadha.app` مثبت، ولن يُزال أو تُمسح بياناته دون موافقة إضافية.

## متابعة QA — 2026-10-10 (مرحلة استكمال الاختبارات)

- الجهاز: Redmi Note 13 Pro متصل في ADB بحالة `device`، وفرع المشروع `dev`، ولا توجد محاولة تثبيت أو حذف للتطبيق خلال هذه المتابعة.
- مجموعة اختبارات انحدار Flutter على 10 ملفات: **29/29 اختبارات ناجحة، exit code 0**. السجل: `docs/device-smoke/cleaning-regression-20261010.log`.
- تشمل المجموعة: حجز التنظيفات على شاشات RTL ضيقة، التحقق من سياسة سلامة العاملات، الجلسات المتكررة والمفتوحة، ملخص السعر والكوبونات، توزيع الغرف، إغلاق نافذة التحقق، وTimeline الطلب.
- تم إصلاح التحذيرات الخاصة باستخدام `RadioListTile.groupValue/onChanged` المتقادمتين باستعمال `RadioGroup<String>` مع الحفاظ على منطق الحظر والتعهد. كذلك أزيل تحذير `unnecessary_underscores` في قائمة العمال السابقين.
- اختبارا `female_worker_safety_radio_group_test.dart` يعيدان التأكد من رفض الخيار المحظور ووجوب التعهد قبل العودة بالبيانات، وقد نجحا ضمن المجموعة.
- `dart analyze lib/core/themes` و`dart analyze lib/features/cl_main/view/widgets` نفذا في المتابعة السابقة بنجاح `No issues found` بعد هذه الإصلاحات.
- محاولتا Android Gradle QA بالمرآة البديلة عُلّقتا في اتصالات HTTPS لتحميل الاعتماديات رغم نجاح اختبار GET مباشر من Java وcurl. أُوقفت Daemons الاختبار العالقة فقط، واستعاد السكربت ملفات Gradle الأصلية. **لم يُنتج APK جديد**؛ آخر APK يعود إلى 2026-07-12.
- **لا يُدّعى اكتمال E2E على الهاتف أو نجاح بناء Android**. بقية تحذيرات Gradle/Kotlin تخص توافق toolchain، ولا ينبغي ترقيتها أو إسكاتها قبل توفر بناء قابل للتحقق.
- حافظنا على سلوك Backend/API والخادم دون تغيير، ولا Commit ولا Push.

## حالة الاتصال الختامية لهذه المتابعة
- أُوقف تحليل Dart الشامل المعلق (PID 19816 و1828) بعد التحقق من أن العمليتين تتبعان أوامر التحليل الخاصة بهذه الجلسة؛ نتائج تحليل مكتمل لمجلد lib ككل غير متاحة.
- نتيجة `git diff --check` لم تعرض أخطاء whitespace، لكنها عرضت تحذيرات تحويل نهايات الأسطر LF/CRLF.
- مساحة القرص المتاحة عند آخر تحقق: حوالي 5.6 GB؛ لم تُحذف Gradle/Flutter caches بشكل شامل مراعاةً للملفات الموجودة.
- بعد نجاح مجموعة الاختبارات، دخل Redmi في حالة ADB `offline` ثم اختفى من `adb devices` بعد محاولة `adb reconnect offline`، رغم ظهور تعريف USB في Windows بحالة سليمة. يتطلب ذلك فتح الهاتف وإعادة توصيل USB وموافقة ADB إن ظهرت.
- لم يُنتج APK جديد ولم يُثبَّت أي تطبيق على الهاتف. آخر APK مؤرخ في يوليو 2026.
