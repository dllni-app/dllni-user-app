import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:common_package/common_package.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/normalize_product_text_model.dart';
import '../../domain/usecases/normalize_product_text_use_case.dart';

class SmartSearchSheet extends StatefulWidget {
  const SmartSearchSheet({super.key, required this.isSupermarket});
  final bool isSupermarket;

  @override
  State<SmartSearchSheet> createState() => _SmartSearchSheetState();
}

abstract final class _SmartSearchColors {
  static const Color blue = Color(0xFF1A237E);
  static const Color orange = Color(0xFFF57C00);
  static const Color micBackground = Color(0xFFF0F0F5);
  static const Color fieldBorder = Color(0xFFE0E0E8);
  static const Color fieldFill = Color(0xFFF9FAFB);
  static const Color hint = Color(0xFF9CA3AF);
}

enum _SmartSearchPhase { input, review }

class _SmartSearchSheetState extends State<SmartSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  final NormalizeProductTextUseCase _normalizeProductTextUseCase =
      getIt<NormalizeProductTextUseCase>();

  _SmartSearchPhase _phase = _SmartSearchPhase.input;
  List<String> _reviewWords = [];

  bool _speechReady = false;
  bool _listening = false;
  bool _isSubmitting = false;

  bool _openMicSession = false;

  /// Locale used for the current / restarted listen sessions.
  String? _activeListenLocaleId;

  /// Snapshot of [TextEditingController] text before each [SpeechToText.listen] call
  /// so auto-restarts do not wipe prior dictation (new session [recognizedWords] is incremental).
  String _listenTranscriptPrefix = '';

  /// 0–1, from [SpeechToText] `onSoundLevelChange` (normalized per listen session).
  double _voiceEnergy = 0;

  double _levelMin = 0;
  double _levelMax = 1;
  bool _levelBoundsReady = false;

  DateTime? _lastSoundAt;
  Timer? _energyDecayTimer;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'البحث الذكي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _SmartSearchColors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_phase == _SmartSearchPhase.input)
                    ..._buildInputPhase(context),
                  if (_phase == _SmartSearchPhase.review)
                    ..._buildReviewPhase(context),
                  const SizedBox(height: 18),
                  if (_phase == _SmartSearchPhase.input) _InfoBanner(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _energyDecayTimer?.cancel();
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  void _backToInput() {
    setState(() {
      _phase = _SmartSearchPhase.input;
      _reviewWords = [];
    });
  }

  List<Widget> _buildInputPhase(BuildContext context) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _fetchNormalizedWords(),
              readOnly: _isSubmitting,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 26 / 14,
              ),
              decoration: InputDecoration(
                suffixIcon: _controller.text.trim().isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: _SmartSearchColors.hint,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                    });
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                filled: true,
                fillColor: _SmartSearchColors.fieldFill,
                hintText: '.. بدي ربطة خبز',
                hintStyle: const TextStyle(
                  color: _SmartSearchColors.hint,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 26 / 14,
                  fontFamily: 'Cairo',
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(right: 14, left: 10),
                  child: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 18,
                    color: _SmartSearchColors.blue,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  maxWidth: 48,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(
                    color: _SmartSearchColors.fieldBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(
                    color: _SmartSearchColors.fieldBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(
                    color: _SmartSearchColors.fieldBorder,
                  ),
                ),
              ),

            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: _SmartSearchColors.micBackground,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _isSubmitting
                  ? null
                  : () async {
                if (_listening) {
                  await _stopListen();
                  return;
                }

                if (_controller.text.trim().isNotEmpty) {
                  await _fetchNormalizedWords();
                  return;
                }

                await _startListen();
              },
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.microphone,
                    size: 18,
                    color: _listening
                        ? Colors.redAccent
                        : _SmartSearchColors.blue,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      if (_isSubmitting) ...[SizedBox(height: 4), LinearProgressIndicator()],
      const SizedBox(height: 14),
      _VoiceLevelLine(energy: _voiceEnergy, isActive: _listening),
    ];
  }

  List<Widget> _buildReviewPhase(BuildContext context) {
    return [
      Text(
        'عدّل الكلمات ثم أكّد',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _SmartSearchColors.blue.withValues(alpha: 0.85),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(_reviewWords.length, (index) {
          final word = _reviewWords[index];
          return InputChip(
            label: Text(
              word,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            onDeleted: () {
              setState(() {
                _reviewWords.removeAt(index);
              });
            },
            deleteIconColor: _SmartSearchColors.blue,
            backgroundColor: _SmartSearchColors.fieldFill,
            side: const BorderSide(color: _SmartSearchColors.fieldBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }),
      ),
      const SizedBox(height: 18),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _backToInput,
              style: OutlinedButton.styleFrom(
                foregroundColor: _SmartSearchColors.blue,
                side: const BorderSide(color: _SmartSearchColors.fieldBorder),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('رجوع'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _confirmReview,
              style: FilledButton.styleFrom(
                backgroundColor: _SmartSearchColors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('تأكيد'),
            ),
          ),
        ],
      ),
    ];
  }

  void _confirmReview() {
    if (_reviewWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف كلمة واحدة على الأقل.')),
      );
      return;
    }
    Navigator.of(context).pop<List<String>>(List<String>.from(_reviewWords));
  }

  Future<void> _ensureSpeech() async {
    if (_speechReady) return;
    final ok = await _speech.initialize(
      onStatus: _onSpeechStatus,
      onError: (_) {},
    );
    if (!mounted) return;
    if (ok) setState(() => _speechReady = true);
  }

  Future<void> _fetchNormalizedWords() async {
    if (_isSubmitting) return;
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اكتب أو سجّل طلبك أولاً.')));
      return;
    }

    setState(() => _isSubmitting = true);
    final locale = context.locale.languageCode;
    final result = await _normalizeProductTextUseCase(
      NormalizeProductTextParams(
        text: trimmed,
        locale: locale,
        isSupermarket: widget.isSupermarket,
      ),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (Failure failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (NormalizeProductTextModel model) {
        if (!mounted) return;
        final words = _wordsFromModel(model, trimmed);
        if (words.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم التعرف على كلمات من الطلب.')),
          );
          return;
        }
        setState(() {
          _reviewWords = words;
          _phase = _SmartSearchPhase.review;
        });
      },
    );
  }

  Future<void> _maybeRestartListenAfterEngineStop() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    if (!_openMicSession) return;
    if (_phase != _SmartSearchPhase.input) return;
    if (_isSubmitting) return;

    try {
      await _speech.stop();
    } catch (_) {}

    final localeId = _activeListenLocaleId ?? await _pickSpeechLocale();

    if (!mounted || localeId == null) return;

    _activeListenLocaleId = localeId;

    try {
      await _runListen(localeId);
    } catch (_) {
      if (!mounted) return;

      _openMicSession = false;

      setState(() {
        _listening = false;
        _voiceEnergy = 0;
      });

      _setListeningVisuals(false);
    }
  }

  void _onSoundLevel(double level) {
    if (!_listening || !mounted) return;
    _lastSoundAt = DateTime.now();
    if (!_levelBoundsReady) {
      _levelMin = level;
      _levelMax = level;
      _levelBoundsReady = true;
    } else {
      _levelMin = min(_levelMin, level);
      _levelMax = max(_levelMax, level);
    }
    final span = max(_levelMax - _levelMin, 0.001);
    var n = ((level - _levelMin) / span).clamp(0.0, 1.0);
    // Slightly more responsive in the mid range.
    n = pow(n, 0.55).toDouble();
    setState(() => _voiceEnergy = n);
  }

  void _onSpeechStatus(String status) {
    if (status != SpeechToText.doneStatus &&
        status != SpeechToText.notListeningStatus) {
      return;
    }

    if (!mounted) return;

    final recentlySpoken =
        _lastRecognizedAt != null &&
            DateTime.now().difference(_lastRecognizedAt!) <
                const Duration(seconds: 5);

    if (_openMicSession &&
        _hasRecognizedSpeech &&
        recentlySpoken &&
        _phase == _SmartSearchPhase.input &&
        !_isSubmitting) {
      unawaited(_maybeRestartListenAfterEngineStop());
      return;
    }

    _openMicSession = false;

    setState(() {
      _listening = false;
      _voiceEnergy = 0;
    });

    _setListeningVisuals(false);
  }

  Future<String?> _pickSpeechLocale() async {
    // final locales = await _speech.locales();
    // for (final locale in locales) {
    //   if (locale.localeId.toLowerCase().startsWith('ar')) {
    //     return locale.localeId;
    //   }
    // }
    // return 'ar_SA';
    return "ar";
  }
  DateTime? _lastRecognizedAt;
  Future<void> _runListen(String localeId) async {
    _listenTranscriptPrefix = _controller.text.trim();
    await _speech.listen(
      onResult: (result) {

        if (!mounted) return;
        final live = result.recognizedWords.trim();
        if (live.isNotEmpty) {
          _hasRecognizedSpeech = true;
          _lastRecognizedAt = DateTime.now();
        }
        if (live.isNotEmpty) {
          _hasRecognizedSpeech = true;
        }
        final composed = _listenTranscriptPrefix.isEmpty
            ? live
            : live.isEmpty
            ? _listenTranscriptPrefix
            : '$_listenTranscriptPrefix $live'.trim();
        setState(() {
          _controller.text = composed;
          _controller.selection = TextSelection.collapsed(
            offset: composed.length,
          );
        });
      },
      onSoundLevelChange: _onSoundLevel,
      localeId: localeId,
      // listenFor: null,
      // pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(minutes: 10),
      pauseFor: const Duration(seconds: 30),

      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  void _setListeningVisuals(bool listening) {
    _energyDecayTimer?.cancel();
    if (!listening) return;
    _energyDecayTimer = Timer.periodic(const Duration(milliseconds: 70), (_) {
      if (!_listening || !mounted) return;
      final last = _lastSoundAt;
      if (last != null &&
          DateTime.now().difference(last) < const Duration(milliseconds: 140)) {
        return;
      }
      setState(() {
        _voiceEnergy = (_voiceEnergy * 0.86).clamp(0.0, 1.0);
      });
    });
  }
  bool _hasRecognizedSpeech = false;
  Future<void> _startListen() async {
    var status = await Permission.microphone.status;

    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('فعّل إذن الميكروفون من إعدادات التطبيق.'),
          action: SnackBarAction(
            label: 'الإعدادات',
            onPressed: openAppSettings,
          ),
        ),
      );
      return;
    }

    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يلزم السماح بالميكروفون للتسجيل الصوتي.'),
        ),
      );
      return;
    }

    await _ensureSpeech();

    if (!_speechReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('التعرف الصوتي غير متاح على هذا الجهاز.'),
        ),
      );
      return;
    }

    final localeId = await _pickSpeechLocale();

    if (!mounted || localeId == null) return;

    _activeListenLocaleId = localeId;
    _openMicSession = true;

    // مهم
    _hasRecognizedSpeech = false;

    _levelBoundsReady = false;
    _levelMin = 0;
    _levelMax = 1;
    _lastSoundAt = null;

    setState(() {
      _listening = true;
      _voiceEnergy = 0;
    });

    _setListeningVisuals(true);

    if (_speech.isListening) return;

    try {
      await _runListen(localeId);
    } catch (_) {
      if (!mounted) return;

      _openMicSession = false;

      setState(() {
        _listening = false;
        _voiceEnergy = 0;
      });

      _setListeningVisuals(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذّر بدء الاستماع. حاول مرة أخرى.'),
        ),
      );
    }
  }

  /// User taps the mic to stop (Google Translate–style): recording runs until this runs, then we normalize.
  Future<void> _stopListen() async {
    if (!_listening) return;
    _openMicSession = false;
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _listening = false;
      _voiceEnergy = 0;
    });
    _setListeningVisuals(false);
    await _fetchNormalizedWords();
  }

  List<String> _wordsFromModel(
    NormalizeProductTextModel model,
    String trimmedFallback,
  )
  {
    if (model.items.isNotEmpty) {
      return List<String>.from(model.items);
    }
    final nt = model.normalizedText?.trim();
    if (nt != null && nt.isNotEmpty) {
      final parts = nt
          .split(RegExp(r'\s*,\s*|،\s*'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) return parts;
    }
    if (trimmedFallback.isNotEmpty) return [trimmedFallback];
    return [];
  }
}

class _VoiceLevelLine extends StatelessWidget {
  final double energy;

  final bool isActive;
  const _VoiceLevelLine({required this.energy, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final t = isActive ? energy : 0.0;
    final height = 3.0 + t * 18.0;
    final glow = isActive ? 6.0 + t * 26.0 : 0.0;

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (isActive && t > 0.04)
            Positioned.fill(
              child: Center(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    height: height + 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          _SmartSearchColors.orange.withValues(alpha: 0.5),
                          _SmartSearchColors.blue.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 72),
              curve: Curves.easeOut,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                gradient: const LinearGradient(
                  colors: [_SmartSearchColors.orange, _SmartSearchColors.blue],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: isActive && t > 0.02
                    ? [
                        BoxShadow(
                          color: _SmartSearchColors.orange.withValues(
                            alpha: 0.42 * (0.35 + t * 0.65),
                          ),
                          blurRadius: glow * 0.6,
                          spreadRadius: t * 1.5,
                          offset: const Offset(-3, 0),
                        ),
                        BoxShadow(
                          color: _SmartSearchColors.blue.withValues(
                            alpha: 0.38 * (0.35 + t * 0.65),
                          ),
                          blurRadius: glow * 0.6,
                          spreadRadius: t * 1.5,
                          offset: const Offset(3, 0),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0x14FF9F43),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0x29FF9F43)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: const FaIcon(
              FontAwesomeIcons.circleInfo,
              color: Color(0xFFFF9F43),
              size: 16,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  'يمكنك طلب مستلزماتك صوتياً',
                  style: TextStyle(
                    color: Color(0xFF9A3412),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                Text(
                  '•  سيتم عرض كل المنتجات المتعلقة بهذا الصنف.',
                  style: TextStyle(
                    color: Color(0xFFC2410C),
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
