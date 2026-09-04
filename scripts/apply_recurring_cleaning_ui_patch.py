from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"Expected one match in {path}, found {count}: {old[:80]!r}")
    file.write_text(text.replace(old, new, 1))


schedule_screen = "lib/features/cl_main/view/screens/cl_main_service_schedule_screen.dart"
replace_once(
    schedule_screen,
    "import '../../domain/models/cleaning_assignment_mode.dart';\nimport '../../domain/models/cleaning_type.dart';",
    "import '../../domain/models/cleaning_assignment_mode.dart';\nimport '../../domain/models/cleaning_recurring_session.dart';\nimport '../../domain/models/cleaning_type.dart';",
)
replace_once(
    schedule_screen,
    "import '../widgets/cl_scheduled_previous_workers_section_widget.dart';\nimport '../widgets/cl_service_address_section_widget.dart';",
    "import '../widgets/cl_recurring_schedule_section_widget.dart';\nimport '../widgets/cl_scheduled_previous_workers_section_widget.dart';\nimport '../widgets/cl_service_address_section_widget.dart';",
)
replace_once(
    schedule_screen,
    "  final Set<String> _selectedCleaningServiceNames = <String>{};\n",
    "  final Set<String> _selectedCleaningServiceNames = <String>{};\n  bool _isRecurring = false;\n  List<CleaningRecurringSessionInput> _recurringSessions =\n      const <CleaningRecurringSessionInput>[];\n",
)
replace_once(
    schedule_screen,
    "                            estimatedHours:\n                                  estimate?.size?.estimatedHours ?? 0,",
    "                            estimatedHours: _perVisitEstimatedHours(estimate),",
)
replace_once(
    schedule_screen,
    "                          ClServiceScheduleSectionWidget(\n                            dayAr: dayAr,\n                            dayDate: dayDate,\n                            fromTimeController: _fromTimeController,\n                            toTimeController: _toTimeController,\n                            onPickDate: _pickDate,\n                            onPickFromTime: _pickFromTime,\n                          ),\n                          const SizedBox(height: 10),\n                          ClServiceGenderPreferenceSectionWidget(",
    "                          ClServiceScheduleSectionWidget(\n                            dayAr: dayAr,\n                            dayDate: dayDate,\n                            fromTimeController: _fromTimeController,\n                            toTimeController: _toTimeController,\n                            onPickDate: _pickDate,\n                            onPickFromTime: _pickFromTime,\n                          ),\n                          const SizedBox(height: 10),\n                          ClRecurringScheduleSectionWidget(\n                            enabled: _isRecurring,\n                            sessions: _recurringSessions,\n                            onEnabledChanged: (enabled) =>\n                                _setRecurringEnabled(enabled, state),\n                            onAddVisit: () => _addRecurringVisit(state),\n                            onEditVisit: (index) =>\n                                _editRecurringVisit(index, state),\n                            onRemoveVisit: (index) =>\n                                _removeRecurringVisit(index, state),\n                          ),\n                          const SizedBox(height: 10),\n                          ClServiceGenderPreferenceSectionWidget(",
)
replace_once(
    schedule_screen,
    "                            durationHours: _effectiveServiceHours(\n                              estimatedHours:\n                                  estimate?.size?.estimatedHours ?? 0,",
    "                            durationHours: _effectiveServiceHours(\n                              estimatedHours: _perVisitEstimatedHours(estimate),",
)
replace_once(
    schedule_screen,
    "  Future<void> _pickDate() async {\n    final tomorrow = CleaningScheduleDateTimeLogic.tomorrowDate();\n    final value = await AppPickers.showAppDatePicker(\n      context: context,\n      startDate: tomorrow,\n      initialDate: _selectedDate,\n    );\n    if (value.isEmpty) return;\n    setState(() {\n      _selectedDate = CleaningScheduleDateTimeLogic.parseDateApi(value)!;\n    });\n  }\n\n  Future<void> _pickFromTime() async {\n    final now = DateTime.now();\n    final isToday =\n        _selectedDate.year == now.year &&\n        _selectedDate.month == now.month &&\n        _selectedDate.day == now.day;\n    final value = await AppPickers.showAppTimePicker(\n      context: context,\n      minimumTime: isToday ? now.add(const Duration(hours: 1)) : null,\n    );\n    if (value.isEmpty) return;\n    setState(() {\n      _fromTimeHhMm = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(value);\n      _syncToTime();\n    });\n  }\n",
    "  Future<void> _pickDate() async {\n    final tomorrow = CleaningScheduleDateTimeLogic.tomorrowDate();\n    final value = await AppPickers.showAppDatePicker(\n      context: context,\n      startDate: tomorrow,\n      initialDate: _selectedDate,\n    );\n    if (value.isEmpty) return;\n    setState(() {\n      _selectedDate = CleaningScheduleDateTimeLogic.parseDateApi(value)!;\n      _replacePrimaryRecurringVisit();\n    });\n    _requestRecurringEstimateIfPossible();\n  }\n\n  Future<void> _pickFromTime() async {\n    final now = DateTime.now();\n    final isToday =\n        _selectedDate.year == now.year &&\n        _selectedDate.month == now.month &&\n        _selectedDate.day == now.day;\n    final value = await AppPickers.showAppTimePicker(\n      context: context,\n      minimumTime: isToday ? now.add(const Duration(hours: 1)) : null,\n    );\n    if (value.isEmpty) return;\n    setState(() {\n      _fromTimeHhMm = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(value);\n      _replacePrimaryRecurringVisit();\n      _syncToTime();\n    });\n    _requestRecurringEstimateIfPossible();\n  }\n\n  List<CleaningRecurringSessionInput> get _recurringSessionsForRequest {\n    if (!_isRecurring || _recurringSessions.length < 2) {\n      return const <CleaningRecurringSessionInput>[];\n    }\n    return _recurringSessions.normalized;\n  }\n\n  double _perVisitEstimatedHours(EstimatePriceResponseModel? estimate) {\n    if (_isRecurring) {\n      final sessions = estimate?.schedule?.sessions;\n      if (sessions != null && sessions.isNotEmpty && sessions.first.hours > 0) {\n        return sessions.first.hours;\n      }\n      final total = estimate?.size?.estimatedHours ?? 0;\n      final count = _recurringSessions.length;\n      if (count >= 2 && total > 0) return total / count;\n    }\n    return estimate?.size?.estimatedHours ?? 0;\n  }\n\n  void _setRecurringEnabled(bool enabled, ClMainState state) {\n    setState(() {\n      _isRecurring = enabled;\n      _recurringSessions = enabled\n          ? <CleaningRecurringSessionInput>[\n              CleaningRecurringSessionInput(\n                date: _selectedDate,\n                time: _fromTimeHhMm,\n              ),\n            ]\n          : const <CleaningRecurringSessionInput>[];\n      _resetAppliedCoupon(\n        message: 'تم تغيير نمط الحجز. أعد تطبيق الكوبون.',\n      );\n    });\n    _requestUpdatedEstimate(state);\n  }\n\n  Future<void> _addRecurringVisit(ClMainState state) async {\n    final tomorrow = CleaningScheduleDateTimeLogic.tomorrowDate();\n    final initialDate = _recurringSessions.isEmpty\n        ? _selectedDate\n        : _recurringSessions.last.date.add(const Duration(days: 7));\n    final dateValue = await AppPickers.showAppDatePicker(\n      context: context,\n      startDate: tomorrow,\n      initialDate: initialDate,\n    );\n    if (!mounted || dateValue.isEmpty) return;\n    final date = CleaningScheduleDateTimeLogic.parseDateApi(dateValue);\n    if (date == null) return;\n\n    final timeValue = await AppPickers.showAppTimePicker(context: context);\n    if (!mounted || timeValue.isEmpty) return;\n    final time = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(timeValue);\n    final next = CleaningRecurringSessionInput(date: date, time: time);\n    if (_recurringSessions.any((session) => session.slotKey == next.slotKey)) {\n      _showDuplicateRecurringVisit();\n      return;\n    }\n\n    _applyRecurringSessions(\n      <CleaningRecurringSessionInput>[..._recurringSessions, next],\n    );\n    _requestUpdatedEstimate(state);\n  }\n\n  Future<void> _editRecurringVisit(int index, ClMainState state) async {\n    if (index < 0 || index >= _recurringSessions.length) return;\n    final current = _recurringSessions[index];\n    final tomorrow = CleaningScheduleDateTimeLogic.tomorrowDate();\n    final dateValue = await AppPickers.showAppDatePicker(\n      context: context,\n      startDate: tomorrow,\n      initialDate: current.date,\n    );\n    if (!mounted || dateValue.isEmpty) return;\n    final date = CleaningScheduleDateTimeLogic.parseDateApi(dateValue);\n    if (date == null) return;\n\n    final timeValue = await AppPickers.showAppTimePicker(context: context);\n    if (!mounted || timeValue.isEmpty) return;\n    final time = CleaningScheduleDateTimeLogic.normalizeTimeHhMm(timeValue);\n    final replacement = CleaningRecurringSessionInput(date: date, time: time);\n    final duplicated = _recurringSessions.indexed.any(\n      (entry) => entry.$1 != index && entry.$2.slotKey == replacement.slotKey,\n    );\n    if (duplicated) {\n      _showDuplicateRecurringVisit();\n      return;\n    }\n\n    final next = _recurringSessions.toList(growable: false);\n    final edited = <CleaningRecurringSessionInput>[...next];\n    edited[index] = replacement;\n    _applyRecurringSessions(edited);\n    _requestUpdatedEstimate(state);\n  }\n\n  void _removeRecurringVisit(int index, ClMainState state) {\n    if (index <= 0 || index >= _recurringSessions.length) return;\n    final next = <CleaningRecurringSessionInput>[..._recurringSessions]\n      ..removeAt(index);\n    _applyRecurringSessions(next);\n    _requestUpdatedEstimate(state);\n  }\n\n  void _applyRecurringSessions(List<CleaningRecurringSessionInput> sessions) {\n    setState(() {\n      _recurringSessions = sessions.normalized;\n      if (_recurringSessions.isNotEmpty) {\n        final first = _recurringSessions.first;\n        _selectedDate = first.date;\n        _fromTimeHhMm = first.time;\n      }\n      _syncToTime();\n      _resetAppliedCoupon(\n        message: 'تم تحديث الزيارات. أعد تطبيق الكوبون.',\n      );\n    });\n  }\n\n  void _replacePrimaryRecurringVisit() {\n    if (!_isRecurring || _recurringSessions.isEmpty) return;\n    final updated = <CleaningRecurringSessionInput>[..._recurringSessions];\n    updated[0] = CleaningRecurringSessionInput(\n      date: _selectedDate,\n      time: _fromTimeHhMm,\n    );\n    _recurringSessions = updated.normalized;\n    final first = _recurringSessions.first;\n    _selectedDate = first.date;\n    _fromTimeHhMm = first.time;\n  }\n\n  void _requestRecurringEstimateIfPossible() {\n    if (!_isRecurring || _recurringSessions.length < 2) return;\n    final bloc = _bloc;\n    if (bloc != null) _requestUpdatedEstimate(bloc.state);\n  }\n\n  void _showDuplicateRecurringVisit() {\n    ScaffoldMessenger.of(context).showSnackBar(\n      const SnackBar(content: Text('لا يمكن إضافة نفس تاريخ ووقت الزيارة مرتين.')),\n    );\n  }\n",
)
replace_once(
    schedule_screen,
    "    final estimatedHours = estimate?.size?.estimatedHours ?? 0;",
    "    final estimatedHours = _perVisitEstimatedHours(estimate);",
)
replace_once(
    schedule_screen,
    "    final estimatedHours = estimateForWorkers.size?.estimatedHours ?? 0;",
    "    final estimatedHours = _perVisitEstimatedHours(estimateForWorkers);",
)
replace_once(
    schedule_screen,
    "    final acceptedPledge = await _showPersonalPropertyPledgeDialog();",
    "    if (_isRecurring && _recurringSessions.length < 2) {\n      ScaffoldMessenger.of(context).showSnackBar(\n        const SnackBar(\n          content: Text('الحجز الدوري يحتاج إلى زيارتين على الأقل.'),\n        ),\n      );\n      return;\n    }\n\n    final acceptedPledge = await _showPersonalPropertyPledgeDialog();",
)
replace_once(
    schedule_screen,
    "          preferredWorkerIds: selectedWorkerIds,\n          cleaningServices: _selectedCleaningServicesPayload(),",
    "          preferredWorkerIds: selectedWorkerIds,\n          recurringSessions: _recurringSessionsForRequest,\n          cleaningServices: _selectedCleaningServicesPayload(),",
)
replace_once(
    schedule_screen,
    "          preferredWorkerIds: workerIds,\n          workerRoomAssignments: workerRoomAssignments.isEmpty",
    "          preferredWorkerIds: workerIds,\n          recurringSessions: _recurringSessionsForRequest,\n          workerRoomAssignments: workerRoomAssignments.isEmpty",
)

schedule_model = "lib/features/orders/data/models/cleaning_booking_schedule_model.dart"
replace_once(
    schedule_model,
    "  final int sequence;\n  final DateTime? date;",
    "  final int sequence;\n  final String? sessionType;\n  final DateTime? date;",
)
replace_once(
    schedule_model,
    "    required this.sequence,\n    this.date,",
    "    required this.sequence,\n    this.sessionType,\n    this.date,",
)
replace_once(
    schedule_model,
    "      sequence: _int(json['sequence']) ?? 1,\n      date: DateTime.tryParse(_string(json['date']) ?? ''),",
    "      sequence: _int(json['sequence']) ?? 1,\n      sessionType: _string(json['sessionType'] ?? json['session_type']),\n      date: DateTime.tryParse(_string(json['date']) ?? ''),",
)

wrapper = "lib/features/orders/view/screens/multi_day_cleaning_order_details_screen.dart"
replace_once(
    wrapper,
    "    required this.orderId,\n    this.initialSessionId,\n  });\n\n  final int orderId;\n  final int? initialSessionId;",
    "    required this.orderId,\n    this.initialSessionId,\n    this.recurring = false,\n  });\n\n  final int orderId;\n  final int? initialSessionId;\n  final bool recurring;",
)
replace_once(
    wrapper,
    "          _WorkerChangeCandidate(session: session, assignment: assignment),",
    "          _WorkerChangeCandidate(\n            session: session,\n            assignment: assignment,\n            recurring: widget.recurring,\n          ),",
)
replace_once(
    wrapper,
    "    if (oldWidget.orderId != widget.orderId) {",
    "    if (oldWidget.orderId != widget.orderId ||\n        oldWidget.recurring != widget.recurring) {",
)
replace_once(
    wrapper,
    "                  'تغيير عامل في يوم قادم',",
    "                  widget.recurring\n                      ? 'تغيير عامل في زيارة قادمة'\n                      : 'تغيير عامل في يوم قادم',",
)
replace_once(
    wrapper,
    "                  'اختر العامل واليوم المطلوب فقط. لن تتأثر الأيام المنفذة أو العمال الآخرون.',",
    "                  widget.recurring\n                      ? 'اختر العامل والزيارة المطلوبة فقط. لن تتأثر الزيارات الأخرى أو العمال الآخرون.'\n                      : 'اختر العامل واليوم المطلوب فقط. لن تتأثر الأيام المنفذة أو العمال الآخرون.',",
)
replace_once(
    wrapper,
    "          'سيتم تحرير ${candidate.workerName} من ${candidate.sessionLabel} فقط، ثم تصبح الخانة متاحة لعامل بديل. بقية أيام المناسبة والعمال لن تتغير.',",
    "          widget.recurring\n              ? 'سيتم تحرير ${candidate.workerName} من ${candidate.sessionLabel} فقط، ثم تصبح الخانة متاحة لعامل بديل. بقية الزيارات والعمال لن تتغير.'\n              : 'سيتم تحرير ${candidate.workerName} من ${candidate.sessionLabel} فقط، ثم تصبح الخانة متاحة لعامل بديل. بقية أيام المناسبة والعمال لن تتغير.',",
)
replace_once(
    wrapper,
    "            'تعذر تغيير العامل. حدّث تفاصيل المناسبة وتأكد أن العامل لم يبدأ التوجه ثم حاول مرة أخرى.',",
    "            widget.recurring\n                ? 'تعذر تغيير العامل. حدّث الزيارات وتأكد أن العامل لم يبدأ التوجه ثم حاول مرة أخرى.'\n                : 'تعذر تغيير العامل. حدّث تفاصيل المناسبة وتأكد أن العامل لم يبدأ التوجه ثم حاول مرة أخرى.',",
)
replace_once(
    wrapper,
    "            initialSessionId: widget.initialSessionId,\n          ),",
    "            initialSessionId: widget.initialSessionId,\n            recurring: widget.recurring,\n          ),",
)
replace_once(
    wrapper,
    "                heroTag: 'event-worker-change-${widget.orderId}',",
    "                heroTag: widget.recurring\n                    ? 'recurring-worker-change-${widget.orderId}'\n                    : 'event-worker-change-${widget.orderId}',",
)
replace_once(
    wrapper,
    "    required this.assignment,\n  });\n\n  final CleaningBookingSessionModel session;\n  final CleaningSessionWorkerAssignmentModel assignment;",
    "    required this.assignment,\n    required this.recurring,\n  });\n\n  final CleaningBookingSessionModel session;\n  final CleaningSessionWorkerAssignmentModel assignment;\n  final bool recurring;",
)
replace_once(
    wrapper,
    "    final parts = <String>['اليوم ${session.sequence}'];",
    "    final parts = <String>[\n      recurring ? 'الزيارة ${session.sequence}' : 'اليوم ${session.sequence}',\n    ];",
)

content = "lib/features/orders/view/screens/multi_day_cleaning_order_details_content.dart"
replace_once(
    content,
    "    required this.orderId,\n    this.initialSessionId,\n  });\n\n  final int orderId;\n  final int? initialSessionId;",
    "    required this.orderId,\n    this.initialSessionId,\n    this.recurring = false,\n  });\n\n  final int orderId;\n  final int? initialSessionId;\n  final bool recurring;",
)
replace_once(
    content,
    "    return schedule != null &&\n        schedule.sessions.isNotEmpty &&",
    "    return !widget.recurring &&\n        schedule != null &&\n        schedule.sessions.isNotEmpty &&",
)
replace_once(
    content,
    "        _error = 'تعذر تحميل تفاصيل أيام المناسبة. حاول مرة أخرى.';",
    "        _error = widget.recurring\n            ? 'تعذر تحميل الزيارات الدورية. حاول مرة أخرى.'\n            : 'تعذر تحميل تفاصيل أيام المناسبة. حاول مرة أخرى.';",
)
replace_once(
    content,
    "      title: 'تأكيد إكمال هذا اليوم',\n      message:\n          'هل تؤكد أن العمل الخاص بهذه الجلسة انتهى؟ سيُغلق هذا اليوم فقط، وتبقى الأيام القادمة ضمن نفس الحجز.',",
    "      title: widget.recurring\n          ? 'تأكيد إكمال هذه الزيارة'\n          : 'تأكيد إكمال هذا اليوم',\n      message: widget.recurring\n          ? 'هل تؤكد أن العمل الخاص بهذه الزيارة انتهى؟ ستُغلق هذه الزيارة فقط، وتبقى الزيارات القادمة ضمن نفس الحجز.'\n          : 'هل تؤكد أن العمل الخاص بهذه الجلسة انتهى؟ سيُغلق هذا اليوم فقط، وتبقى الأيام القادمة ضمن نفس الحجز.',",
)
replace_once(
    content,
    "      title: 'إلغاء هذا اليوم فقط',",
    "      title: widget.recurring ? 'إلغاء هذه الزيارة فقط' : 'إلغاء هذا اليوم فقط',",
)
replace_once(
    content,
    "      title: 'تأكيد إلغاء اليوم ${session.sequence}',\n      message:\n          'سيتم إلغاء هذه الجلسة فقط وتحرير العمال المرتبطين بها. الأيام المنفذة وباقي الأيام لن تُلغى.',",
    "      title: widget.recurring\n          ? 'تأكيد إلغاء الزيارة ${session.sequence}'\n          : 'تأكيد إلغاء اليوم ${session.sequence}',\n      message: widget.recurring\n          ? 'سيتم إلغاء هذه الزيارة فقط وتحرير العمال المرتبطين بها. الزيارات المنفذة وبقية الزيارات لن تُلغى.'\n          : 'سيتم إلغاء هذه الجلسة فقط وتحرير العمال المرتبطين بها. الأيام المنفذة وباقي الأيام لن تُلغى.',",
)
replace_once(
    content,
    "      appBar: AppBar(\n        title: const Text('تفاصيل المناسبة'),",
    "      appBar: AppBar(\n        title: Text(\n          widget.recurring ? 'تفاصيل الحجز الدوري' : 'تفاصيل المناسبة',\n        ),",
)
replace_once(
    content,
    "              tooltip: 'تعديل أيام المناسبة',",
    "              tooltip: widget.recurring ? 'تعديل الزيارات' : 'تعديل أيام المناسبة',",
)
replace_once(
    content,
    "                        ? 'مساعدة مناسبة - ${schedule.daysCount} أيام'\n                        : 'مساعدة مناسبة #$bookingNumber',",
    "                        ? (widget.recurring\n                              ? 'حجز تنظيف دوري - ${schedule.daysCount} زيارات'\n                              : 'مساعدة مناسبة - ${schedule.daysCount} أيام')\n                        : (widget.recurring\n                              ? 'حجز تنظيف دوري #$bookingNumber'\n                              : 'مساعدة مناسبة #$bookingNumber'),",
)
replace_once(
    content,
    "          'أيام التنفيذ',",
    "          widget.recurring ? 'الزيارات' : 'أيام التنفيذ',",
)
replace_once(
    content,
    "            'كل يوم هو جلسة تنفيذ مستقلة داخل نفس رقم الحجز. إكمال يوم لا يغلق المناسبة قبل انتهاء آخر جلسة مطلوبة.',",
    "            widget.recurring\n                ? 'كل زيارة مستقلة داخل نفس رقم الحجز. غياب عامل أو استبداله في زيارة لا يلغي الزيارات الأخرى.'\n                : 'كل يوم هو جلسة تنفيذ مستقلة داخل نفس رقم الحجز. إكمال يوم لا يغلق المناسبة قبل انتهاء آخر جلسة مطلوبة.',",
)
replace_once(
    content,
    "                  'اليوم ${session.sequence} من $totalDays',",
    "                  widget.recurring\n                      ? 'الزيارة ${session.sequence} من $totalDays'\n                      : 'اليوم ${session.sequence} من $totalDays',",
)
replace_once(
    content,
    "            label: const Text('تأكيد إكمال هذا اليوم'),",
    "            label: Text(\n              widget.recurring\n                  ? 'تأكيد إكمال هذه الزيارة'\n                  : 'تأكيد إكمال هذا اليوم',\n            ),",
)
replace_once(
    content,
    "                    label: const Text('إلغاء هذا اليوم'),",
    "                    label: Text(\n                      widget.recurring ? 'إلغاء الزيارة' : 'إلغاء هذا اليوم',\n                    ),",
)

order_details = "lib/features/orders/view/screens/cleaning_order_details_screen.dart"
replace_once(
    order_details,
    "import '../widgets/cleaning_room_assignments_section_widget.dart';\nimport '../widgets/cleaning_team_search_banner_widget.dart';",
    "import '../widgets/cleaning_recurring_schedule_launcher_widget.dart';\nimport '../widgets/cleaning_room_assignments_section_widget.dart';\nimport '../widgets/cleaning_team_search_banner_widget.dart';",
)
replace_once(
    order_details,
    "                    if (searchingForWorkers) ...[",
    "                    if (!CleaningEventAssistanceHelper.isEventAssistance(\n                      order.propertyType,\n                    ))\n                      CleaningRecurringScheduleLauncherWidget(\n                        orderId: _activeOrderId,\n                        onReturn: () => _fetchDetails(showLoading: false),\n                      ),\n                    if (searchingForWorkers) ...[",
)

print('Recurring cleaning UI patch applied successfully.')
