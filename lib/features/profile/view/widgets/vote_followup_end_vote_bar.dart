import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/bloc/profile_bloc.dart';

class VoteFollowupEndVoteBar extends StatelessWidget {
  const VoteFollowupEndVoteBar({super.key, required this.voteId});

  final int voteId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: BlocBuilder<ProfileBloc, ProfileState>(
            buildWhen: (previous, current) =>
                previous.endVoteStatus != current.endVoteStatus,
            builder: (context, state) {
              final isEnding = state.endVoteStatus == BlocStatus.loading;
              return ElevatedButton(
                onPressed: isEnding
                    ? null
                    : () => context.read<ProfileBloc>().add(
                        EndVoteEvent(voteId: voteId),
                      ),
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  shadowColor: Colors.black.withAlpha(30),
                  minimumSize: const Size.fromHeight(42),
                  backgroundColor: context.primary,
                  foregroundColor: context.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isEnding
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : AppText.labelLarge(
                        'إنهاء التصويت الآن',
                        color: context.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
