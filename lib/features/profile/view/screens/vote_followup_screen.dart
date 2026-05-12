import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:dllni_user_app/core/app_config.dart';
import 'package:dllni_user_app/core/deeplink/deep_link_share_targets.dart';
import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/core/session/session_expired_handler.dart';
import 'package:dllni_user_app/features/profile/domain/usecases/show_vote_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import '../widgets/vote_winner_bottom_sheet.dart';
import '../widgets/vote_winner_dialog.dart';

class VoteFollowupScreenParams {
  final int voteId;
  final VoteCreatedData? initialData;
  final bool? needShare;

  const VoteFollowupScreenParams({required this.voteId, this.initialData, this.needShare = false});
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
  bool _canEndVote = true;
  bool _pendingWinnerDialog = false;
  bool _handledTimeExpired = false;
  bool _hasSeenPositiveRemaining = false;
  int? _submittingOptionId;
  int? _selectedOptionId;

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  String? _pusherVoteChannelName;

  List<VoteFollowupOptionData> _options = const <VoteFollowupOptionData>[];

  List<String> _voters = const <String>[];

  @override
  void initState() {
    super.initState();
    if (widget.params.needShare == true) {
      unawaited(
        shareDeepLinkUrl(
          voteUrl(widget.params.voteId),
          context: context,
        ),
      );
    }
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
        apiKey: AppConfig.pusherKey,
        cluster: AppConfig.pusherCluster,
        useTLS: true,
        authEndpoint: '${AppConfig.baseUrl}/broadcasting/auth',
        onAuthorizer: (channelName_, socketId, dynamic options) async {
          try {
            final token = (SharedPreferencesHelper.getData(key: 'token') ?? '').toString();
            final res = await DioNetwork.dio.post<Map<String, dynamic>>(
              '/broadcasting/auth',
              data: <String, dynamic>{'channel_name': channelName_, 'socket_id': socketId},
              options: Options(
                headers: <String, dynamic>{
                  'Accept': 'application/json',
                  'X-Requested-With': 'XMLHttpRequest',
                  if (token.isNotEmpty) 'Authorization': 'Bearer $token',
                },
                contentType: Headers.formUrlEncodedContentType,
                responseType: ResponseType.json,
              ),
            );
            final body = res.data;
            if (body == null || body['auth'] == null) {
              throw StateError('Invalid broadcasting auth response');
            }
            return <String, dynamic>{'auth': body['auth'], if (body['channel_data'] != null) 'channel_data': body['channel_data']};
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
      result.fold((Failure f) => debugPrint('Vote Pusher refresh failed: ${f.message}'), _hydrateFromVoteDetails);
    });
  }

  void _startTimer() {
    if (_remaining.inSeconds <= 0) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final previousRemaining = _remaining;
      setState(() {
        if (_remaining.inSeconds <= 1) {
          _remaining = Duration.zero;
          timer.cancel();
        } else {
          _remaining -= const Duration(seconds: 1);
        }
      });
      _handleRemainingTransition(previous: previousRemaining, next: _remaining);
    });
  }

  void _hydrateFromCreatedData(VoteCreatedData? createdData) {
    if (createdData == null) return;
    _syncRemainingFromSeconds(createdData.vote?.secondsRemaining, canTriggerExpiry: false);
    _canEndVote = createdData.vote?.isCreator ?? _canEndVote;
    _options = createdData.options.map(_mapVoteOption).toList();
    if (createdData.voters.isNotEmpty) {
      _voters = createdData.voters.map((e) => e.name?.trim() ?? '').where((e) => e.isNotEmpty).toList();
    } else {
      _voters = const <String>[];
    }
  }

  VoteFollowupOptionData _mapVoteOption(VoteOptionModel option) {
    final percent = (option.percent ?? 0).clamp(0, 100).toDouble();
    final unitPrice = option.unitPrice;
    return VoteFollowupOptionData(
      optionId: option.id,
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

    final voteMap = rawData['vote'] is Map ? Map<String, dynamic>.from(rawData['vote'] as Map) : rawData;
    final seconds = _toInt(voteMap['secondsRemaining']) ?? _toInt(rawData['secondsRemaining']);
    final isCreator = _toBool(voteMap['isCreator']) ?? _toBool(rawData['isCreator']);

    List<VoteFollowupOptionData>? nextOptions;
    if (rawData['options'] is List) {
      nextOptions = (rawData['options'] as List)
          .whereType<Map>()
          .map((e) => VoteOptionModel.fromJson(Map<String, dynamic>.from(e)))
          .map(_mapVoteOption)
          .toList();
    }

    List<String>? nextVoters;
    if (rawData['voters'] is List) {
      nextVoters = (rawData['voters'] as List)
          .map((e) {
            if (e is Map) {
              final map = Map<String, dynamic>.from(e);
              return _toStringValue(map['name']) ?? _toStringValue(map['fullName']) ?? _toStringValue(map['displayName']) ?? '';
            }
            return _toStringValue(e) ?? '';
          })
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    // Read the current user's voted option id from the server payload if available.
    // The API may return it as `myVotedOptionId`, `userVoteOptionId`, or `selectedOptionId`.
    final serverSelectedId =
        _toInt(voteMap['myVotedOptionId']) ??
        _toInt(rawData['myVotedOptionId']) ??
        _toInt(voteMap['userVoteOptionId']) ??
        _toInt(rawData['userVoteOptionId']) ??
        _toInt(voteMap['selectedOptionId']) ??
        _toInt(rawData['selectedOptionId']);

    if (seconds == null && nextOptions == null && nextVoters == null && isCreator == null && serverSelectedId == null) {
      return;
    }

    setState(() {
      _syncRemainingFromSeconds(seconds);
      if (nextOptions != null) {
        _options = nextOptions;
      }
      if (nextVoters != null) {
        _voters = nextVoters;
      }
      if (isCreator != null) {
        _canEndVote = isCreator;
      }
      // Prefer server-authoritative selection; keep local optimistic value if server has none.
      if (serverSelectedId != null) {
        _selectedOptionId = serverSelectedId;
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

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = '$value'.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') {
      return true;
    }
    if (normalized == 'false' || normalized == '0') {
      return false;
    }
    return null;
  }

  void _syncRemainingFromSeconds(int? secondsRemaining, {bool canTriggerExpiry = true}) {
    if (secondsRemaining == null) return;
    final previousRemaining = _remaining;
    final safeSeconds = secondsRemaining < 0 ? 0 : secondsRemaining;
    _remaining = Duration(seconds: safeSeconds);
    if (safeSeconds > 0) {
      _hasSeenPositiveRemaining = true;
    }
    if (safeSeconds > 0) {
      if (_timer == null || !_timer!.isActive) {
        _startTimer();
      }
    } else {
      _timer?.cancel();
      _timer = null;
    }
    if (canTriggerExpiry) {
      _handleRemainingTransition(previous: previousRemaining, next: _remaining);
    }
  }

  void _handleRemainingTransition({required Duration previous, required Duration next}) {
    if (_handledTimeExpired) return;
    if (next.inSeconds > 0) {
      _hasSeenPositiveRemaining = true;
      return;
    }
    if (!_hasSeenPositiveRemaining || previous.inSeconds <= 0) {
      return;
    }
    _handledTimeExpired = true;
    unawaited(_handleVoteTimeExpired());
  }

  Future<void> _handleVoteTimeExpired() async {
    final winnerData = await _resolveWinnerDataForSheet();
    if (!mounted) return;
    context.pushRouteAndRemoveUntil('/rsmain', predicate: (route) => route.isFirst);
    _showWinnerBottomSheetOnRoot(winnerData);
  }

  Future<_WinnerSheetData> _resolveWinnerDataForSheet() async {
    String? winnerName;
    try {
      final result = await getIt<ShowVoteUseCase>()(ShowVoteParams(voteId: widget.params.voteId));
      result.fold((_) {}, (vote) {
        winnerName = vote.winnerLabel?.trim();
        final rawWinner = vote.rawData?['winner'];
        if (rawWinner is Map) {
          final winnerMap = Map<String, dynamic>.from(rawWinner);
          winnerName ??= _toStringValue(winnerMap['label'])?.trim();
        }
      });
    } catch (_) {}

    if (winnerName == null || winnerName!.isEmpty) {
      VoteFollowupOptionData? leadingOption;
      for (final option in _options) {
        if (leadingOption == null || option.votes > leadingOption.votes) {
          leadingOption = option;
        }
      }
      winnerName = leadingOption?.name.trim();
    }

    final safeWinnerName = (winnerName == null || winnerName!.isEmpty) ? 'بيتزا مارغريتا' : winnerName!;
    return _WinnerSheetData(winnerName: safeWinnerName);
  }

  void _showWinnerBottomSheetOnRoot(_WinnerSheetData winnerData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rootContext = SessionExpiredHandler.navigatorKey?.currentContext;
      if (rootContext == null || !rootContext.mounted) {
        return;
      }
      showModalBottomSheet<void>(
        context: rootContext,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) {
          return VoteWinnerBottomSheet(
            winnerName: winnerData.winnerName,
            onShowBestOfferTap: () {
              Navigator.of(rootContext).pop();
              ScaffoldMessenger.maybeOf(rootContext)?.showSnackBar(const SnackBar(content: Text('سيتم ربط أفضل عرض قريباً')));
            },
          );
        },
      );
    });
  }

  void _submitBallot(int optionId, ProfileBloc bloc) {
    if (_submittingOptionId != null) return;
    setState(() {
      _submittingOptionId = optionId;
      _selectedOptionId = optionId;
    });
    bloc.add(SubmitVoteBallotEvent(voteId: widget.params.voteId, optionId: optionId));
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
            previous.voteDetailsStatus != current.voteDetailsStatus ||
            previous.voteBallotStatus != current.voteBallotStatus,
        listener: (context, state) {
          if (state.voteBallotStatus == BlocStatus.failed || state.voteBallotStatus == BlocStatus.success) {
            setState(() {
              _submittingOptionId = null;
            });
          }
          if (state.endVoteStatus == BlocStatus.success) {
            _pendingWinnerDialog = true;
          }
          if (state.voteDetailsStatus == BlocStatus.success) {
            _hydrateFromVoteDetails(state.voteDetails);
            if (_pendingWinnerDialog) {
              _pendingWinnerDialog = false;
              _showWinnerDialog(state.voteDetails?.winnerLabel);
            }
          }
          if (state.errorMessage == null || state.errorMessage!.isEmpty) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        },
        child: Scaffold(
          backgroundColor: const Color(0xffF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                PersonalDetailsAppBar(
                  title: 'متابعة التصويت',
                  trailing: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 42, minHeight: 42),
                    onPressed: () {
                      unawaited(shareDeepLinkUrl(voteUrl(widget.params.voteId), context: context));
                    },
                    icon: FaIcon(FontAwesomeIcons.shareNodes, color: context.primary, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
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
                          child: BlocBuilder<ProfileBloc, ProfileState>(
                            buildWhen: (previous, current) => previous.voteBallotStatus != current.voteBallotStatus,
                            builder: (context, state) {
                              final isSubmittingBallot = state.voteBallotStatus == BlocStatus.loading;
                              return Column(
                                children: _options
                                    .map(
                                      (option) => VoteFollowupOptionCard(
                                        option: option,
                                        onTap: option.optionId == null || isSubmittingBallot
                                            ? null
                                            : () => _submitBallot(option.optionId!, context.read<ProfileBloc>()),
                                        isSubmitting: isSubmittingBallot && _submittingOptionId == option.optionId,
                                        isDisabled: option.optionId == null || (isSubmittingBallot && _submittingOptionId != option.optionId),
                                        isSelected: option.optionId != null && option.optionId == _selectedOptionId,
                                      ),
                                    )
                                    .toList()
                                    .separatedBy(const SizedBox(height: 14)),
                              );
                            },
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
                VoteFollowupEndVoteBar(voteId: widget.params.voteId, canEndVote: _canEndVote),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WinnerSheetData {
  const _WinnerSheetData({required this.winnerName});

  final String winnerName;
}
