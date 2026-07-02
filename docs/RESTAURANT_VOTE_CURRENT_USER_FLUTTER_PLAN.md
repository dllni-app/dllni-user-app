# Restaurant Vote Current User Flutter Fix Plan

## Goal

Update the restaurant voting flow in `dllni-user-app` to consume the new backend payload from `dllni_backend` and fix the UI gaps where a user reopens a vote and cannot see which option they voted for.

Backend source of truth:

- `GET /api/v1/user/restaurants/votes/{voteId}`
- The request must include the logged-in user's `Authorization: Bearer <token>` header when available.
- The response now includes `vote.creator`, `vote.currentUserVote`, backward-compatible selected-option aliases, and `options[*].isSelectedByCurrentUser`.
- Realtime `vote.updated` events are neutral and require a REST refetch.

## Current Flutter gaps found

### 1. Vote follow-up screen does not always refetch on open

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

Current behavior:

- `ShowVoteEvent` is dispatched only when `initialData == null`.
- When opening from existing active votes or after creating a vote with `initialData`, the screen may render stale/partial data.

Required behavior:

- Always dispatch `ShowVoteEvent(voteId)` in `initState` or the bloc `create` block.
- Keep `initialData` only as optimistic first paint.
- Replace state with server payload after the show response returns.

### 2. Models do not parse the new backend fields

File: `lib/features/profile/data/models/profile_api_models.dart`

Missing fields/classes:

- `VoteCreatorModel`
- `CurrentUserVoteModel`
- `VoteModel.creator`
- `VoteModel.currentUserVote`
- `VoteModel.currentUserOptionId`
- `VoteModel.selectedOptionId`
- `VoteModel.myVotedOptionId`
- `VoteModel.userVoteOptionId`
- `VoteModel.hasCurrentUserVoted`
- `VoteOptionModel.isSelectedByCurrentUser`
- `VoteVoterModel.optionId`, `optionLabel`, `isCurrentUser`

Required behavior:

- Parse all new fields with null-safe helpers.
- Keep existing raw payload support for backward compatibility.
- Treat `0` selected id as no selection.

### 3. `_hydrateFromCreatedData` does not hydrate selected option

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

Current behavior:

- It hydrates timer, creator flag, options, and voters.
- It does not set `_selectedOptionId` from the vote payload or option flags.

Required behavior:

- Set `_selectedOptionId` using the same selection resolver used for full REST payloads.
- This prevents the UI from losing selection immediately after navigating to the follow-up screen.

### 4. `_hydrateFromVotePayload` does not read `currentUserVote` or option selection flags

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

Current behavior:

- It reads `myVotedOptionId`, `userVoteOptionId`, and `selectedOptionId`.
- It does not prioritize `vote.currentUserVote.optionId`.
- It does not fallback to `options[*].isSelectedByCurrentUser`.

Required behavior:

Create one helper, for example `_resolveSelectedOptionId(rawData)`, with this priority:

1. `data.vote.currentUserVote.optionId`
2. `data.vote.currentUserOptionId`
3. `data.vote.selectedOptionId`
4. `data.vote.myVotedOptionId`
5. `data.vote.userVoteOptionId`
6. first option where `isSelectedByCurrentUser == true`

Rules:

- Return `null` when the value is `null`, `0`, or invalid.
- Always overwrite local `_selectedOptionId` from server payload, including clearing it when backend returns no selection.

### 5. Submit ballot flow relies on follow-up refetch but should hydrate deterministically

Files:

- `lib/features/profile/data/source/profile_remote_data_source.dart`
- `lib/features/profile/domain/repository/profile_repo.dart`
- `lib/features/profile/data/repository/profile_repo_impl.dart`
- `lib/features/profile/domain/usecases/submit_vote_ballot_use_case.dart`
- `lib/features/profile/view/manager/bloc/profile_bloc.dart`

Current behavior:

- `submitVoteBallot` parses the response as `ActionResultModel`.
- The backend returns the full vote payload under `data`.
- Bloc currently dispatches `ShowVoteEvent` after ballot success, which is good, but UI can flicker because optimistic state is not immediately reconciled with response data.

Implementation options:

Option A, preferred:

- Change `submitVoteBallot` return type from `ActionResultModel` to `CreateVoteModel` or a dedicated `VoteDetailsActionModel` that carries `VoteCreatedData` / raw data.
- In bloc success, update `voteDetails` or a dedicated `lastVotePayload` immediately, then optionally refetch to guarantee consistency.

Option B, lower-risk:

- Keep `ActionResultModel` return type.
- Keep dispatching `ShowVoteEvent` after success.
- Make sure the screen keeps the loading icon only until either `voteBallotStatus` success or `voteDetailsStatus` success.

Recommended: Option A if changing repository signatures is acceptable; otherwise Option B is enough for the bug because show refetch is the source of truth.

### 6. Realtime handler must always refetch

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

Current behavior:

- `_onVoteRealtimeEvent` tries to hydrate directly from event payload.
- It only refetches when expected fields are missing.

Backend changed behavior:

- Realtime payload is intentionally neutral.
- It should not be used to determine selected option.

Required behavior:

- On every `vote.updated`, call `_scheduleVoteFallbackRefresh(fallbackReason: 'vote_updated')` or direct `_refreshVoteFromPusher()`.
- Do not call `_hydrateFromVotePayload` for realtime payload except maybe to update timer temporarily.
- The REST refetch must be the final state update.

### 7. End-vote visibility should use server owner state

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

Current behavior:

- `_canEndVote` is updated from `vote.isCreator`.

Required behavior:

- Keep this, but also ensure it is refreshed after the show endpoint returns.
- Hide or disable `VoteFollowupEndVoteBar` when `status != active` if that status becomes available in local state.
- Use `vote.creator.isCurrentUser` only as a display helper; the action decision should remain `vote.isCreator`.

## Detailed implementation tasks

### Task 1: Update vote models

File: `lib/features/profile/data/models/profile_api_models.dart`

Add:

```dart
class VoteCreatorModel {
  final int? id;
  final String? name;
  final String? avatarUrl;
  final bool isCurrentUser;
}

class CurrentUserVoteModel {
  final bool hasVoted;
  final int? optionId;
  final String? optionLabel;
  final int? ballotId;
  final String? votedAt;
}
```

Extend `VoteModel`:

```dart
final VoteCreatorModel? creator;
final CurrentUserVoteModel? currentUserVote;
final int? currentUserOptionId;
final int? selectedOptionId;
final int? myVotedOptionId;
final int? userVoteOptionId;
final bool hasCurrentUserVoted;
```

Extend `VoteOptionModel`:

```dart
final bool isSelectedByCurrentUser;
```

Extend `VoteVoterModel`:

```dart
final int? optionId;
final String? optionLabel;
final bool isCurrentUser;
```

### Task 2: Fix `ShowVoteModel` parsing

File: `lib/features/profile/data/models/profile_api_models.dart`

Current `ShowVoteModel` only stores `voteId`, `winnerLabel`, and `rawData`.

Add:

```dart
final VoteCreatedData? data;
```

Parse it from `json['data']` using `VoteCreatedData.fromJson(data)`.

Keep `rawData` because `VoteFollowupScreen` already depends on it.

### Task 3: Add selected-option resolver

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

Add helper methods:

```dart
int? _normalizeSelectedOptionId(dynamic value) {
  final id = _toInt(value);
  return id == null || id <= 0 ? null : id;
}

int? _resolveSelectedOptionId(Map<String, dynamic> rawData) {
  final voteMap = rawData['vote'] is Map
      ? Map<String, dynamic>.from(rawData['vote'] as Map)
      : rawData;

  final currentUserVote = voteMap['currentUserVote'] is Map
      ? Map<String, dynamic>.from(voteMap['currentUserVote'] as Map)
      : const <String, dynamic>{};

  final direct = _normalizeSelectedOptionId(currentUserVote['optionId']) ??
      _normalizeSelectedOptionId(voteMap['currentUserOptionId']) ??
      _normalizeSelectedOptionId(voteMap['selectedOptionId']) ??
      _normalizeSelectedOptionId(voteMap['myVotedOptionId']) ??
      _normalizeSelectedOptionId(voteMap['userVoteOptionId']);

  if (direct != null) return direct;

  final options = rawData['options'];
  if (options is List) {
    for (final option in options) {
      if (option is Map && _toBool(option['isSelectedByCurrentUser']) == true) {
        return _normalizeSelectedOptionId(option['id']);
      }
    }
  }

  return null;
}
```

### Task 4: Always refresh vote details on screen open

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

Change bloc creation from:

```dart
if (widget.params.initialData == null) {
  bloc.add(ShowVoteEvent(voteId: widget.params.voteId));
}
```

to:

```dart
bloc.add(ShowVoteEvent(voteId: widget.params.voteId));
```

This guarantees creator and selected-option state is server-authoritative when the user returns to the screen.

### Task 5: Hydrate selected state from created data

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

In `_hydrateFromCreatedData`, after mapping options/voters, build a temporary raw map or use `createdData.vote` and `createdData.options` to resolve selection.

Set:

```dart
_selectedOptionId = resolvedSelectedOptionId;
```

Do not preserve stale local selection if server says no selection.

### Task 6: Hydrate selected state from REST payload correctly

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

Replace current `serverSelectedId` logic with `_resolveSelectedOptionId(rawData)`.

In `setState`, always assign:

```dart
_selectedOptionId = resolvedSelectedOptionId;
```

This is important for deselect behavior. If backend returns `0` or `null`, the UI must clear the selected radio/check icon.

### Task 7: Realtime event should refetch, not directly hydrate

File: `lib/features/profile/view/screens/vote_followup_screen.dart`

Change `_onVoteRealtimeEvent` to:

```dart
void _onVoteRealtimeEvent(RealtimeEvent event) {
  if (!mounted) return;
  _scheduleVoteFallbackRefresh(fallbackReason: 'vote_updated');
}
```

Optional: read `secondsRemaining` from the neutral payload for immediate timer sync, but still refetch.

### Task 8: Submit ballot UX cleanup

Files:

- `vote_followup_screen.dart`
- `profile_bloc.dart`

Keep optimistic `_selectedOptionId = optionId` on tap for fast feedback.

On ballot success:

- Clear `_submittingOptionId`.
- Wait for `ShowVoteEvent` result to override `_selectedOptionId`.
- If the same option was tapped and backend toggled off, `_selectedOptionId` becomes null after show refresh.

Optional improvement:

- Change submit ballot use case to parse full vote response and hydrate immediately before the follow-up `ShowVoteEvent`.

### Task 9: Update active votes list hydration

Files:

- `order_voting_screen.dart`
- `profile_api_models.dart`

The active votes endpoint returns `VoteCreatedData` entries. Ensure `VoteModel.currentUserVote` and selected ids are parsed there too.

When building `OrderVotingCreatedPollItem`, keep passing `initialData`, but follow-up screen must still refetch.

### Task 10: Add tests

Recommended widget/unit tests:

1. `VoteModel.fromJson` parses `creator` and `currentUserVote`.
2. `VoteOptionModel.fromJson` parses `isSelectedByCurrentUser`.
3. `_resolveSelectedOptionId` returns `currentUserVote.optionId` first.
4. `_resolveSelectedOptionId` returns null when backend returns `0` or null.
5. `VoteFollowupScreen` dispatches `ShowVoteEvent` even when `initialData` exists.
6. `vote.updated` calls show/refetch instead of trusting event payload.
7. Tapping the selected option clears the UI after backend returns deselection state.

## Acceptance criteria

- Creator creates a vote, votes for an option, leaves the screen, opens it again, and the selected option is highlighted.
- A non-creator user sees only their own selected option, not the creator's selection.
- Anonymous shared-link view shows creator data but no current-user selection.
- If user taps the same option again, selection is cleared after the backend response/refetch.
- Realtime changes from another user update counts but do not mark their option as selected for the current user.
- End vote button appears only for the creator.
- No regressions in active votes, vote creation, vote end, or vote sharing.

## Suggested implementation order

1. Update models.
2. Update selected-option resolver in `VoteFollowupScreen`.
3. Always refetch on screen open.
4. Change realtime to always refetch.
5. Fix submit/deselect hydration.
6. Update active votes handling if needed.
7. Add tests.
8. Manual QA on a real device using two different users.
