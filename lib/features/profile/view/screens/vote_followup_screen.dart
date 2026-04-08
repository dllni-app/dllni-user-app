import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:dllni_user_app/core/app_config.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/show_vote_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../../data/models/profile_api_models.dart';
import '../manager/bloc/profile_bloc.dart';
import '../widgets/expandable_numbered_section.dart';
import '../widgets/list_widgets_separated.dart';
import '../widgets/personal_details_app_bar.dart';
import '../widgets/vote_followup_end_vote_bar.dart';
import '../widgets/vote_followup_option_card.dart';
import '../widgets/vote_followup_option_data.dart';
import '../widgets/vote_followup_timer_banner.dart';
import '../widgets/vote_followup_voters_list.dart';
import '../widgets/vote_winner_dialog.dart';

/// Pusher Channels public key (must match backend). Never ship [PUSHER_APP_SECRET] in the app.
const String _kVotePusherKey = 'e85e7756c1171baaa471';
const String _kVotePusherCluster = 'eu';

class VoteFollowupScreenParams {
  final int voteId;
  final VoteCreatedData? initialData;

  const VoteFollowupScreenParams({required this.voteId, this.initialData});
}

@AutoRoutePage()
class VoteFollowupScreen extends StatefulWidget {
  const VoteFollowupScreen({super.key, required this.params});

  final VoteFollowupScreenParams params;

  @override
  State<VoteFollowupScreen> createState() => _VoteFollowupScreenState();
}

class _VoteFollowupScreenState extends State<VoteFollowupScreen> {
  static const Duration _initialDuration = Duration(minutes: 30);
  Timer? _timer;
  Duration _remaining = _initialDuration;
  bool _isOptionsExpanded = true;
  bool _isVotersExpanded = true;

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  String? _pusherVoteChannelName;

  List<VoteFollowupOptionData> _options = const [
    VoteFollowupOptionData(
      name: 'بيتزا مارغريتا',
      size: 'وسط',
      price: '450 ل.س',
      progress: 0.5,
      votes: 4,
    ),
    VoteFollowupOptionData(
      name: 'بيتزا مارغريتا',
      size: 'وسط',
      price: '450 ل.س',
      progress: 0.5,
      votes: 4,
    ),
  ];

  List<String> _voters = const [
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
    _hydrateFromCreatedData(widget.params.initialData);
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_connectVoteRealtime());
    });
  }

  Future<void> _connectVoteRealtime() async {
    if (!mounted) return;
    final voteId = widget.params.voteId;
    final channelName = 'private-vote.$voteId';
    _pusherVoteChannelName = channelName;

    try {
      await _pusher.init(
        apiKey: _kVotePusherKey,
        cluster: _kVotePusherCluster,
        authEndpoint: '${AppConfig.baseUrl}/broadcasting/auth',
        onAuthorizer: (channelName_, socketId, dynamic options) async {
          try {
            final res = await DioNetwork.dio.post<Map<String, dynamic>>(
              '/broadcasting/auth',
              data: <String, dynamic>{
                'channel_name': channelName_,
                'socket_id': socketId,
              },
              options: Options(
                contentType: Headers.formUrlEncodedContentType,
                responseType: ResponseType.json,
              ),
            );
            final body = res.data;
            if (body == null || body['auth'] == null) {
              throw StateError('Invalid broadcasting auth response');
            }
            return <String, dynamic>{
              'auth': body['auth'],
              if (body['channel_data'] != null) 'channel_data': body['channel_data'],
            };
          } catch (e, st) {
            debugPrint('Vote Pusher auth error: $e\n$st');
            rethrow;
          }
        },
        onSubscriptionError: (message, e) {
          debugPrint('Vote Pusher subscription error: $message $e');
        },
        onError: (message, code, e) {
          debugPrint('Vote Pusher error: $message code=$code $e');
        },
        onEvent: (PusherEvent event) {
          if (event.eventName != 'vote.updated' || event.channelName != channelName) {
            return;
          }
          _refreshVoteFromPusher();
        },
      );
      if (!mounted) return;
      await _pusher.connect();
      if (!mounted) return;
      await _pusher.subscribe(channelName: channelName);
    } catch (e, st) {
      debugPrint('Vote Pusher connect failed: $e\n$st');
    }
  }

  void _refreshVoteFromPusher() {
    getIt<ShowVoteUseCase>()(ShowVoteParams(voteId: widget.params.voteId)).then((Either<Failure, ShowVoteModel> result) {
      if (!mounted) return;
      result.fold(
        (Failure f) => debugPrint('Vote Pusher refresh failed: ${f.message}'),
        _hydrateFromVoteDetails,
      );
    });
  }

  void _startTimer() {
    _timer?.cancel();
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

  void _hydrateFromCreatedData(VoteCreatedData? createdData) {
    if (createdData == null) return;
    final seconds = createdData.vote?.secondsRemaining;
    if (seconds != null && seconds > 0) {
      _remaining = Duration(seconds: seconds);
    }
    if (createdData.options.isNotEmpty) {
      _options = createdData.options.map(_mapVoteOption).toList();
    }
    if (createdData.voters.isNotEmpty) {
      _voters = createdData.voters
          .map((e) => e.name?.trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      _voters = const <String>[];
    }
  }

  VoteFollowupOptionData _mapVoteOption(VoteOptionModel option) {
    final percent = (option.percent ?? 0).clamp(0, 100).toDouble();
    final unitPrice = option.unitPrice;
    return VoteFollowupOptionData(
      name: option.label ?? '-',
      size: 'افتراضي',
      price: unitPrice == null ? '-' : '$unitPrice \$',
      progress: percent / 100,
      votes: option.voteCount ?? 0,
    );
  }

  void _hydrateFromVoteDetails(ShowVoteModel? voteDetails) {
    final rawData = voteDetails?.rawData;
    if (rawData == null) return;

    Duration? nextRemaining;
    final seconds = _toInt(rawData['secondsRemaining']);
    if (seconds != null && seconds > 0) {
      nextRemaining = Duration(seconds: seconds);
    }

    List<VoteFollowupOptionData>? nextOptions;
    if (rawData['options'] is List) {
      final mapped = (rawData['options'] as List)
          .whereType<Map>()
          .map((e) => VoteOptionModel.fromJson(Map<String, dynamic>.from(e)))
          .map(_mapVoteOption)
          .toList();
      if (mapped.isNotEmpty) {
        nextOptions = mapped;
      }
    }

    List<String>? nextVoters;
    if (rawData['voters'] is List) {
      nextVoters = (rawData['voters'] as List)
          .map((e) {
            if (e is Map) {
              final map = Map<String, dynamic>.from(e);
              return _toStringValue(map['name']) ??
                  _toStringValue(map['fullName']) ??
                  _toStringValue(map['displayName']) ??
                  '';
            }
            return _toStringValue(e) ?? '';
          })
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    if (nextRemaining == null && nextOptions == null && nextVoters == null) {
      return;
    }

    setState(() {
      if (nextRemaining != null) {
        _remaining = nextRemaining;
      }
      if (nextOptions != null) {
        _options = nextOptions;
      }
      if (nextVoters != null) {
        _voters = nextVoters;
      }
    });
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  String? _toStringValue(dynamic value) {
    if (value == null) return null;
    return '$value';
  }

  @override
  void dispose() {
    _timer?.cancel();
    final channel = _pusherVoteChannelName;
    if (channel != null) {
      unawaited(_pusher.unsubscribe(channelName: channel).catchError((Object _) {}));
    }
    unawaited(_pusher.disconnect().catchError((Object _) {}));
    super.dispose();
  }

  void _showWinnerDialog(String? winnerLabel) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return VoteWinnerDialog(
          winnerName: winnerLabel ?? 'بيتزا مارغريتا',
          onShowBestOfferTap: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('سيتم ربط أفضل عرض قريباً')),
            );
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
    return BlocProvider<ProfileBloc>(
      lazy: false,
      create: (_) {
        final bloc = getIt<ProfileBloc>();
        if (widget.params.initialData == null) {
          bloc.add(ShowVoteEvent(voteId: widget.params.voteId));
        }
        return bloc;
      },
      child: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (previous, current) =>
            previous.endVoteStatus != current.endVoteStatus ||
            previous.voteDetailsStatus != current.voteDetailsStatus,
        listener: (context, state) {
          if (state.endVoteStatus == BlocStatus.success) {
            _showWinnerDialog(state.voteDetails?.winnerLabel);
            return;
          }
          if (state.voteDetailsStatus == BlocStatus.success) {
            _hydrateFromVoteDetails(state.voteDetails);
          }
          if (state.errorMessage == null || state.errorMessage!.isEmpty) {
            return;
          }
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                const PersonalDetailsAppBar(title: 'متابعة التصويت'),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      0,
                      16,
                      24,
                    ),
                    child: Column(
                      children: [
                        VoteFollowupTimerBanner(formattedTime: _formattedTime),
                        const SizedBox(height: 16),
                        ExpandableNumberedSection(
                          sectionNumber: '1',
                          title: 'خيارات التصويت',
                          isExpanded: _isOptionsExpanded,
                          onHeaderTap: () {
                            setState(() {
                              _isOptionsExpanded = !_isOptionsExpanded;
                            });
                          },
                          child: Column(
                            children: _options
                                .map(
                                  (option) =>
                                      VoteFollowupOptionCard(option: option),
                                )
                                .toList()
                                .separatedBy(const SizedBox(height: 14)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ExpandableNumberedSection(
                          sectionNumber: '2',
                          title: 'أسماء المصوتين',
                          isExpanded: _isVotersExpanded,
                          onHeaderTap: () {
                            setState(() {
                              _isVotersExpanded = !_isVotersExpanded;
                            });
                          },
                          child: VoteFollowupVotersList(voterNames: _voters),
                        ),
                      ],
                    ),
                  ),
                ),
                VoteFollowupEndVoteBar(voteId: widget.params.voteId),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
