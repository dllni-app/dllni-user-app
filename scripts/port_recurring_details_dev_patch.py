from pathlib import Path

path = Path("lib/features/orders/view/screens/cleaning_order_details_screen.dart")
text = path.read_text()

import_line = "import '../widgets/cleaning_recurring_schedule_launcher_widget.dart';\n"
if import_line not in text:
    marker = "import '../widgets/cleaning_preferred_worker_card_widget.dart';\n"
    if text.count(marker) != 1:
        raise SystemExit(f"launcher import marker count: {text.count(marker)}")
    text = text.replace(marker, marker + import_line, 1)

launcher = '''                    if (!CleaningEventAssistanceHelper.isEventAssistance(
                      order.propertyType,
                    ))
                      CleaningRecurringScheduleLauncherWidget(
                        orderId: _activeOrderId,
                        onReturn: () => _fetchDetails(showLoading: false),
                      ),
'''
if launcher not in text:
    marker = "                    if (searchingForWorkers) ...[\n"
    if text.count(marker) != 1:
        raise SystemExit(f"launcher insertion marker count: {text.count(marker)}")
    text = text.replace(marker, launcher + marker, 1)

path.write_text(text)
