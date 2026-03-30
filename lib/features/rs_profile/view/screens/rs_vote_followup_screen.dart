import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';

import '../widgets/rs_expandable_numbered_section.dart';
import '../widgets/rs_personal_details_app_bar.dart';
import '../widgets/rs_vote_winner_dialog.dart';

@AutoRoutePage()
class RsVoteFollowupScreen extends StatefulWidget {
  const RsVoteFollowupScreen({super.key});

  @override
  State<RsVoteFollowupScreen> createState() => _RsVoteFollowupScreenState();
}

class _RsVoteFollowupScreenState extends State<RsVoteFollowupScreen> {
  static const Duration _initialDuration = Duration(minutes: 30);
  Timer? _timer;
  Duration _remaining = _initialDuration;
  bool _isOptionsExpanded = true;
  bool _isVotersExpanded = true;

  static const List<_VotingOption> _options = [
    _VotingOption(name: 'بيتزا مارغريتا', size: 'وسط', price: '450 ل.س', progress: 0.5, votes: 4),
    _VotingOption(name: 'بيتزا مارغريتا', size: 'وسط', price: '450 ل.س', progress: 0.5, votes: 4),
  ];

  static const List<String> _voters = [
    'خالد جمعاني',
    'مصطفى فارس',
    'أحمد البيطار',
    'حسام تحسين بيك',
    'فؤاد خيرات بيك',
    'أحمد محمد',
    'أبو مصطفى الحلبي',
    'أحمد سنبل',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remaining.inSeconds <= 1) {
          _remaining = Duration.zero;
          timer.cancel();
        } else {
          _remaining -= const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showWinnerDialog() {
    showDialog<void>(
      context: context,
      builder: (_) {
        return RsVoteWinnerDialog(
          winnerName: 'بيتزا مارغريتا',
          onShowBestOfferTap: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سيتم ربط أفضل عرض قريباً')));
          },
        );
      },
    );
  }

  String get _formattedTime {
    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours : $minutes : $seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const RsPersonalDetailsAppBar(title: 'متابعة التصويت'),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.onPrimary,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 14, offset: const Offset(0, 3))],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: AppText.displayMedium(
                        _formattedTime,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        color: context.primaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RsExpandableNumberedSection(
                      sectionNumber: '1',
                      title: 'خيارات التصويت',
                      isExpanded: _isOptionsExpanded,
                      onHeaderTap: () {
                        setState(() {
                          _isOptionsExpanded = !_isOptionsExpanded;
                        });
                      },
                      child: Column(
                        children: _options.map((option) => _VotingOptionCard(option: option)).toList().separatedBy(const SizedBox(height: 14)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    RsExpandableNumberedSection(
                      sectionNumber: '2',
                      title: 'أسماء المصوتين',
                      isExpanded: _isVotersExpanded,
                      onHeaderTap: () {
                        setState(() {
                          _isVotersExpanded = !_isVotersExpanded;
                        });
                      },
                      child: Column(
                        children: _voters.asMap().entries.map((entry) {
                          final index = entry.key + 1;
                          final name = entry.value;
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(bottom: 6),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: AppText.bodyMedium('$index- $name', color: const Color(0xff374151)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showWinnerDialog,
                    style: ElevatedButton.styleFrom(
                      elevation: 4,
                      shadowColor: Colors.black.withAlpha(30),
                      minimumSize: const Size.fromHeight(42),
                      backgroundColor: context.primary,
                      foregroundColor: context.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: AppText.labelLarge('إنهاء التصويت الآن', color: context.onPrimary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VotingOption {
  const _VotingOption({required this.name, required this.size, required this.price, required this.progress, required this.votes});

  final String name;
  final String size;
  final String price;
  final double progress;
  final int votes;
}

class _VotingOptionCard extends StatelessWidget {
  const _VotingOptionCard({required this.option});

  final _VotingOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.only(top: 16),
            child: Icon(Icons.radio_button_unchecked, color: Color(0xffD1D5DB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.local_pizza_outlined, color: Color(0xffD97706)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.bodyLarge(option.name, fontWeight: FontWeight.w700, color: const Color(0xff1F2937)),
                          AppText.bodySmall('الحجم: ${option.size}', color: const Color(0xff6B7280)),
                          AppText.bodySmall('السعر: ${option.price}', color: const Color(0xff6B7280)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AppText.labelLarge('(${option.votes})', color: const Color(0xff6B7280), fontWeight: FontWeight.w700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: option.progress,
                          minHeight: 8,
                          backgroundColor: const Color(0xffFDEDD8),
                          valueColor: AlwaysStoppedAnimation<Color>(context.primaryContainer),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    AppText.labelLarge('${(option.progress * 100).toInt()}%', color: context.primaryContainer, fontWeight: FontWeight.w700),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _SeparatedWidgets on List<Widget> {
  List<Widget> separatedBy(Widget separator) {
    if (isEmpty) {
      return [];
    }
    final result = <Widget>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}
