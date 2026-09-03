from pathlib import Path


def replace(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    if old not in text:
        raise SystemExit(f"pattern not found in {path}: {old[:120]!r}")
    file.write_text(text.replace(old, new, 1))


# Add PATCH schedule API to the current session data source.
path = "lib/features/orders/data/source/cleaning_session_remote_data_source.dart"
marker = """  Future<CleaningMultiDayOrderEnvelope> _post(\n    String endpoint, {\n    Map<String, dynamic>? data,\n  }) {\n"""
replace(
    path,
    marker,
    """  Future<CleaningMultiDayOrderEnvelope> updateSchedule({\n    required int orderId,\n    required List<Map<String, dynamic>> sessions,\n  }) {\n    return wrapHandlingApi(\n      tryCall: () => dioNetwork.patchData(\n        endPoint: '/api/v1/user/cleaning/orders/$orderId',\n        data: <String, dynamic>{\n          'schedule': <String, dynamic>{\n            'mode': sessions.length > 1 ? 'multi_day' : 'single_day',\n            'sessions': sessions,\n          },\n        },\n      ),\n      jsonConvert: cleaningMultiDayOrderEnvelopeFromJson,\n    );\n  }\n\n""" + marker,
)

# Remove stale imports and an old arbitrary 31-day UI cap; backend owns validation.
path = "lib/features/orders/view/screens/multi_day_cleaning_order_reschedule_screen.dart"
file = Path(path)
text = file.read_text()
text = text.replace("import 'package:common_package/common_package.dart';\n", "")
text = text.replace("import '../../data/models/cleaning_booking_schedule_model.dart';\n", "")
text = text.replace("    if (!_editAllowed || _sessions.length >= 31) return;\n", "    if (!_editAllowed) return;\n")
text = text.replace(
    """    if (_sessions.length > 31) {\n      _showMessage('الحد الأعلى هو 31 جلسة.');\n      return;\n    }\n\n""",
    "",
)
file.write_text(text)

# Link rescheduling from the multi-day event details screen.
path = "lib/features/orders/view/screens/multi_day_cleaning_order_details_screen.dart"
replace(
    path,
    "import '../../data/source/cleaning_session_remote_data_source.dart';\n",
    "import '../../data/source/cleaning_session_remote_data_source.dart';\nimport 'multi_day_cleaning_order_reschedule_screen.dart';\n",
)
replace(
    path,
    """  CleaningBookingScheduleModel? get _schedule => _envelope?.schedule;\n  CleaningSessionRemoteDataSource get _sessions =>\n      getIt<CleaningSessionRemoteDataSource>();\n""",
    """  CleaningBookingScheduleModel? get _schedule => _envelope?.schedule;\n  CleaningSessionRemoteDataSource get _sessions =>\n      getIt<CleaningSessionRemoteDataSource>();\n\n  bool get _canReschedule {\n    final schedule = _schedule;\n    return schedule != null &&\n        schedule.sessions.isNotEmpty &&\n        schedule.sessions.every((session) => session.canReschedule == true);\n  }\n""",
)
marker = """  Future<void> _confirmStartVerification(\n    CleaningBookingSessionModel session,\n  ) async {\n"""
replace(
    path,
    marker,
    """  Future<void> _openReschedule() async {\n    if (!_canReschedule) return;\n\n    final changed = await Navigator.of(context).push<bool>(\n      MaterialPageRoute(\n        builder: (_) => MultiDayCleaningOrderRescheduleScreen(\n          orderId: widget.orderId,\n        ),\n      ),\n    );\n\n    if (changed == true && mounted) {\n      await _load();\n    }\n  }\n\n""" + marker,
)
replace(
    path,
    """      appBar: AppBar(title: const Text('تفاصيل المناسبة'), centerTitle: true),\n""",
    """      appBar: AppBar(\n        title: const Text('تفاصيل المناسبة'),\n        centerTitle: true,\n        actions: [\n          if (_canReschedule)\n            IconButton(\n              tooltip: 'تعديل أيام المناسبة',\n              onPressed: _openReschedule,\n              icon: const Icon(Icons.edit_calendar_outlined),\n            ),\n        ],\n      ),\n""",
)

# Make the multi-day session view reachable from the normal event booking details.
path = "lib/features/orders/view/screens/cleaning_order_details_screen.dart"
replace(
    path,
    "import 'cleaning_order_sos_screen.dart';\n",
    "import 'cleaning_order_sos_screen.dart';\nimport 'multi_day_cleaning_order_details_screen.dart';\n",
)
needle = """                            _SummaryRow(\n                              title: 'مدة الحجز',\n                              value: CleaningEventAssistanceHelper.formatHours(\n                                CleaningEventAssistanceHelper.resolveBookedHours(\n                                  propertyHours: order.propertyDetails?.hours,\n                                  totalHours: order.totalHours,\n                                  estimatedHours: double.tryParse(\n                                    order.estimatedHours ?? '',\n                                  ),\n                                ),\n                              ),\n                            ),\n"""
replacement = needle + """                            const SizedBox(height: 12),\n                            OutlinedButton.icon(\n                              onPressed: () async {\n                                await Navigator.of(context).push<void>(\n                                  MaterialPageRoute(\n                                    builder: (_) =>\n                                        MultiDayCleaningOrderDetailsScreen(\n                                          orderId: _activeOrderId,\n                                        ),\n                                  ),\n                                );\n                                if (mounted) {\n                                  await _fetchDetails(showLoading: false);\n                                }\n                              },\n                              icon: const Icon(Icons.event_note_outlined),\n                              label: const Text('عرض أيام وجلسات المناسبة'),\n                            ),\n"""
replace(path, needle, replacement)

# Model test for backend-owned reschedule capability. Keep it inside main().
path = "test/features/orders/data/models/cleaning_booking_schedule_model_test.dart"
file = Path(path)
text = file.read_text()
closing = "\n}\n"
if not text.endswith(closing):
    raise SystemExit(f"unexpected test file ending in {path}")
test_block = """

  test('parses backend event schedule reschedule capability', () {
    final envelope = cleaningMultiDayOrderEnvelopeFromJson(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 501,
        'status': 'pending',
        'schedule': <String, dynamic>{
          'mode': 'multi_day',
          'sessions': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 1,
              'sequence': 1,
              'date': '2026-09-20',
              'time': '09:00',
              'hours': 2,
              'status': 'scheduled',
              'canReschedule': true,
            },
            <String, dynamic>{
              'id': 2,
              'sequence': 2,
              'date': '2026-09-21',
              'time': '09:00',
              'hours': 2,
              'status': 'scheduled',
              'canReschedule': true,
            },
          ],
        },
      },
    });

    expect(envelope.schedule?.sessions, hasLength(2));
    expect(
      envelope.schedule?.sessions.every(
        (session) => session.canReschedule == true,
      ),
      isTrue,
    );
  });
"""
file.write_text(text[:-len(closing)] + test_block + closing)
