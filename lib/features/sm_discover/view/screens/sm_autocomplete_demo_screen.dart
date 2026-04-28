import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Local catalog for trying [Autocomplete] behavior (RTL / Arabic) before wiring into search.
@AutoRoutePage(path: '/sm_autocomplete_demo')
class SmAutocompleteDemoScreen extends StatelessWidget {
  const SmAutocompleteDemoScreen({super.key});

  static const List<String> _demoProducts = [
    'خبز',
    'خبز صامولي',
    'خبز لبناني',
    'حليب',
    'حليب مكثف',
    'لبن المراعي',
    'رز بسمتي',
    'رز كبسة',
    'قهوة',
    'قهوة عربية',
    'طحين',
    'طحين كاتو',
    'سكر',
    'زيت',
  ];

  static Iterable<String> _optionsForQuery(String raw) {
    final q = raw.trim();
    if (q.length < 2) return const Iterable<String>.empty();
    final starts = _demoProducts.where((w) => w.startsWith(q));
    if (starts.isNotEmpty) return starts;
    return _demoProducts.where((w) => w.contains(q));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تجربة Autocomplete'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppText(
              'نسخة مخصصة بالكامل. اكتب حرفين على الأقل لتظهر الإكمالات داخل نفس السطر.',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
              ),
            ),
            const SizedBox(height: 16),
            AppText(
              'Custom Autocomplete',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SmSpecialAutocompleteField(
              optionsForQuery: _optionsForQuery,
            ),
            const SizedBox(height: 24),
            AppText(
              'هذه شاشة تجريبية فقط — القائمة ثابتة في الكود.',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SmSpecialAutocompleteField extends StatefulWidget {
  const SmSpecialAutocompleteField({
    super.key,
    required this.optionsForQuery,
  });

  final Iterable<String> Function(String raw) optionsForQuery;

  @override
  State<SmSpecialAutocompleteField> createState() =>
      _SmSpecialAutocompleteFieldState();
}

class _SmSpecialAutocompleteFieldState extends State<SmSpecialAutocompleteField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _hintOption;
  bool _dismissedForCurrentInput = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateHint(String value) {
    if (_dismissedForCurrentInput || value.trim().length < 2) {
      if (_hintOption != null) setState(() => _hintOption = null);
      return;
    }

    final options = widget.optionsForQuery(value).toList(growable: false);
    final first = options.isEmpty ? null : options.first;
    final hint = (first != null && first.startsWith(value) && first != value)
        ? first
        : null;

    if (hint != _hintOption) {
      setState(() => _hintOption = hint);
    }
  }

  void _acceptHint() {
    final selected = _hintOption;
    if (selected == null) return;
    _controller.value = TextEditingValue(
      text: selected,
      selection: TextSelection.collapsed(offset: selected.length),
    );
    setState(() {
      _hintOption = null;
      _dismissedForCurrentInput = false;
    });
  }

  void _dismissHint() {
    if (_hintOption != null || !_dismissedForCurrentInput) {
      setState(() {
        _hintOption = null;
        _dismissedForCurrentInput = true;
      });
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _dismissHint();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab && _hintOption != null) {
      _acceptHint();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final typed = _controller.text;
    final tail = (_hintOption != null && _hintOption!.startsWith(typed))
        ? _hintOption!.substring(typed.length)
        : null;
    final hasHint = tail != null && tail.isNotEmpty;
    const fieldTextStyle = TextStyle(
      color: Color(0xFF111827),
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 26 / 14,
    );
    const hintTailStyle = TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 26 / 14,
    );
    const strutStyle = StrutStyle(
      fontSize: 14,
      height: 26 / 14,
      leading: 0,
      forceStrutHeight: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (hasHint)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: IconButton(
                  tooltip: 'قبول الاقتراح',
                  onPressed: _acceptHint,
                  icon: const Icon(Icons.check_rounded),
                ),
              ),
            Expanded(
              child: Focus(
                onKeyEvent: _handleKeyEvent,
                child: GestureDetector(
                  onTap: () => _focusNode.requestFocus(),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      end: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20, color: Color(0xFF1E2A78)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  child: IgnorePointer(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: RichText(
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                          textAlign: TextAlign.right,
                                          textDirection: TextDirection.rtl,
                                          strutStyle: strutStyle,
                                          text: TextSpan(
                                            children: [
                                              if (typed.isEmpty && !hasHint)
                                                const TextSpan(
                                                  text: 'ابحث (Tab/الأيقونة للقبول, Esc للإلغاء)...',
                                                  style: TextStyle(
                                                    color: Color(0xFF9CA3AF),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    height: 26 / 14,
                                                  ),
                                                )
                                              else if (hasHint)
                                                TextSpan(
                                                  text: _hintOption,
                                                  style: hintTailStyle,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 11),
                                  child: EditableText(
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    style: fieldTextStyle,
                                    strutStyle: strutStyle,
                                    cursorColor: const Color(0xFF1E2A78),
                                    backgroundCursorColor: const Color(0xFF9CA3AF),
                                    cursorWidth: 2.2,
                                    cursorRadius: const Radius.circular(2),
                                    selectionColor: const Color(0x331E2A78),
                                    enableInteractiveSelection: true,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.search,
                                    onSubmitted: (_) => _acceptHint(),
                                    onChanged: (value) {
                                      if (_dismissedForCurrentInput) {
                                        _dismissedForCurrentInput = false;
                                      }
                                      _updateHint(value);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AppText(
          'Desktop: Tab للقبول / Esc للإلغاء - Mobile: زر الصح للقبول.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
