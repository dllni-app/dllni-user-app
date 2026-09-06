from pathlib import Path

path = Path('test/features/cl_main/view/widgets/cl_recurring_schedule_section_widget_test.dart')
text = path.read_text()
marker = "  ) async {\n"
count = text.count(marker)
if count != 4:
    raise SystemExit(f'expected 4 widget-test async bodies, found {count}')
setup = (
    marker
    + "    tester.view.devicePixelRatio = 1.0;\n"
    + "    tester.view.physicalSize = const Size(800, 1200);\n"
    + "    addTearDown(tester.view.resetPhysicalSize);\n"
    + "    addTearDown(tester.view.resetDevicePixelRatio);\n"
)
text = text.replace(marker, setup)
path.write_text(text)
print('recurring worker scope widget viewport normalized')
