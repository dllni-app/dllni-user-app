import 'package:flutter/material.dart';
import '../../data/models/cleaning_orders_api_models.dart';

/// Customer-facing V2 order details, organized by visit rather than time period.
class CleaningTimePeriodsSummary extends StatelessWidget {
  const CleaningTimePeriodsSummary({super.key, required this.order});
  final CleaningOrderDetailModel order;

  List<Map<String, dynamic>> _maps(dynamic raw) => [
    for (final item in raw is List ? raw : const [])
      if (item is Map) Map<String, dynamic>.from(item),
  ];

  Map<String, dynamic> _room(String key) =>
      order.bookingRooms.where((room) => room['roomKey'] == key).firstOrNull ??
      {};

  String _roomName(String key) {
    final name = switch (_room(key)['roomType'] ?? key.split('.').first) {
      'bedroom' => 'غرفة نوم',
      'bathroom' => 'حمام',
      'toilet' => 'مرحاض',
      'kitchen' => 'مطبخ',
      'living_room' => 'غرفة معيشة',
      'balcony' => 'شرفة',
      'corridor' => 'ممر',
      'shed' => 'مستودع',
      _ => 'غرفة',
    };
    return name + ' ' + key.split('.').last;
  }

  String _mode(String key) => switch (_room(key)['cleaningMode']) {
    'regular' => 'حوسة',
    'deep' => 'تعزيل',
    _ => 'غير محدد',
  };
  String _size(String key) => switch (_room(key)['size']) {
    'small' => 'صغيرة',
    'medium' => 'متوسطة',
    'large' => 'كبيرة',
    _ => '',
  };
  String _time(dynamic date) =>
      RegExp(r'T(\d{2}:\d{2})').firstMatch(date?.toString() ?? '')?.group(1) ??
      '';
  String _date(dynamic input) {
    final value = input?.toString() ?? '';
    return value.length >= 10 ? value.substring(0, 10) : '';
  }

  String _supplier(String choice) => switch (choice) {
    'platform_all' => 'مواد التنظيف من المنصة',
    'customer_partial' => 'توفير المواد الناقصة المختارة',
    'customer_all' => 'جميع مواد التنظيف متوفرة لدى العميل',
    _ => 'مواد التنظيف حسب اختيار العميل',
  };
  String _unitLabel(String unit) => switch (unit.toLowerCase().trim()) {
    'pack' || 'package' || 'bottle' => 'عبوة',
    'liter' || 'litre' || 'l' => 'لتر',
    'piece' || 'pcs' => 'قطعة',
    'kg' || 'kilogram' => 'كغ',
    _ => unit,
  };

  String _quantity(dynamic value) {
    final number = value is num ? value : num.tryParse(value?.toString() ?? '');
    if (number == null) return value?.toString() ?? '';
    return number % 1 == 0 ? number.toInt().toString() : number.toString();
  }

  String _serviceName(Map<String, dynamic> service) {
    final name = service['name']?.toString() ?? '';
    if (name.trim().isNotEmpty) return name;
    final id = (service['specialServiceId'] as num?)?.toInt();
    for (final line in order.specialServices) {
      if (line.specialServiceId == id) return line.name ?? 'خدمة متخصصة';
    }
    return 'خدمة متخصصة';
  }

  Widget _visit(Map<String, dynamic> visit, int index) {
    final rooms = _maps(visit['roomSchedules']);
    final periods = _maps(visit['timePeriods']);
    final start = visit['startAt'] ?? rooms.firstOrNull?['startAt'];
    final end = visit['endAt'] ?? rooms.lastOrNull?['endAt'];
    final visitDate = _date(start).isNotEmpty
        ? _date(start)
        : (rooms.firstOrNull?['scheduledDate']?.toString() ?? '');
    final time = _time(start).isNotEmpty
        ? _time(start)
        : (rooms.firstOrNull?['scheduledTime']?.toString() ?? '');
    final materials = <String>{
      for (final period in periods)
        _supplier((period['materials'] as Map?)?['choice']?.toString() ?? ''),
    };
    final supplies = [
      for (final period in periods) ..._maps(period['platformMaterials']),
    ];
    final services = [
      for (final period in periods) ..._maps(period['specialServices']),
    ];
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE0E6EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.event_outlined, color: Color(0xFF008B86)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الزيارة ' + (visit['sequence'] ?? index + 1).toString(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(visitDate),
              ],
            ),
            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'الموعد: من ' +
                      time +
                      (_time(end).isEmpty ? '' : ' إلى ' + _time(end)),
                ),
              ),
            const Divider(height: 26),
            const Text(
              'الغرف والأعمال المطلوبة',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            for (final schedule in rooms)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.meeting_room_outlined,
                      size: 20,
                      color: Color(0xFF008B86),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _roomName(schedule['roomKey']?.toString() ?? ''),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _size(schedule['roomKey']?.toString() ?? '') +
                                ' · ' +
                                _mode(schedule['roomKey']?.toString() ?? '') +
                                ' · العمال: ' +
                                (schedule['numberOfWorkers'] ?? '—')
                                    .toString() +
                                (schedule['estimatedDurationMinutes'] == null
                                    ? ''
                                    : ' · ' +
                                          schedule['estimatedDurationMinutes']
                                              .toString() +
                                          ' دقيقة'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (materials.isNotEmpty) ...[
              const Divider(height: 26),
              const Text(
                'مواد التنظيف',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              for (final choice in materials)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(choice),
                ),
              for (final supply in supplies)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '• ' +
                        (supply['name'] ?? 'مادة تنظيف').toString() +
                        (supply['quantity'] == null
                            ? ''
                            : ' · ' +
                                  _quantity(supply['quantity']) +
                                  ' ' +
                                  _unitLabel(
                                    (supply['unit'] ?? '').toString(),
                                  )),
                  ),
                ),
            ],
            if (services.isNotEmpty) ...[
              const Divider(height: 26),
              const Text(
                'الخدمات المتخصصة',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              for (final service in services)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '• ' +
                        _serviceName(service) +
                        ' · ' +
                        (service['targetRoomKeys'] is List
                            ? (service['targetRoomKeys'] as List)
                                  .map((key) => _roomName(key.toString()))
                                  .join('، ')
                            : '') +
                        ' · الكمية ' +
                        (service['quantity'] ?? 1).toString() +
                        (service['dirtinessLevel'] == 'heavy'
                            ? ' · اتساخ شديد'
                            : service['dirtinessLevel'] == 'light'
                            ? ' · اتساخ بسيط'
                            : ''),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'مواعيد الخدمة وتفاصيل الغرف',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        for (var i = 0; i < order.bookingVisits.length; i++)
          _visit(order.bookingVisits[i], i),
      ],
    ),
  );
}
