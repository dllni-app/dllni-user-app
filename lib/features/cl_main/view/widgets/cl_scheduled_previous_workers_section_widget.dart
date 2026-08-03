import 'dart:async';

import 'package:common_package/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/previous_workers_response_model.dart';
import '../../domain/usecases/get_previous_cleaning_workers_use_case.dart';
import '../helpers/cl_previous_workers_gender_filter.dart';
import '../manager/bloc/cl_main_bloc.dart';
import '../screens/cl_worker_profile_detail_screen.dart';
import 'cl_service_previous_workers_section_widget.dart';

class ClScheduledPreviousWorkersSectionWidget extends StatefulWidget {
  const ClScheduledPreviousWorkersSectionWidget({
    required this.bloc,
    required this.propertyType,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.durationHours,
    required this.onSelectedWorkersChanged,
    super.key,
  });

  final ClMainBloc bloc;
  final String propertyType;
  final String scheduledDate;
  final String scheduledTime;
  final double durationHours;
  final ValueChanged<List<int>> onSelectedWorkersChanged;

  @override
  State<ClScheduledPreviousWorkersSectionWidget> createState() =>
      _ClScheduledPreviousWorkersSectionWidgetState();
}

class _ClScheduledPreviousWorkersSectionWidgetState
    extends State<ClScheduledPreviousWorkersSectionWidget> {
  BlocStatus _status = BlocStatus.init;
  String? _errorMessage;
  List<PreviousWorkerModel> _workers = const <PreviousWorkerModel>[];
  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    scheduleMicrotask(_loadWorkers);
  }

  @override
  void didUpdateWidget(
    covariant ClScheduledPreviousWorkersSectionWidget oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.propertyType != widget.propertyType ||
        oldWidget.scheduledDate != widget.scheduledDate ||
        oldWidget.scheduledTime != widget.scheduledTime ||
        oldWidget.durationHours != widget.durationHours) {
      _loadWorkers();
    }
  }

  Future<void> _loadWorkers() async {
    final requestVersion = ++_requestVersion;
    if (mounted) {
      setState(() {
        _status = BlocStatus.loading;
        _errorMessage = null;
      });
    }

    final response = await getIt<GetPreviousCleaningWorkersUseCase>()(
      GetPreviousCleaningWorkersParams(
        page: 1,
        perPage: 20,
        propertyType: widget.propertyType,
        scheduledDate: widget.scheduledDate,
        scheduledTime: widget.scheduledTime,
        durationHours: widget.durationHours,
      ),
    );

    if (!mounted || requestVersion != _requestVersion) return;

    response.fold(
      (failure) {
        setState(() {
          _status = BlocStatus.failed;
          _errorMessage = failure.message;
          _workers = const <PreviousWorkerModel>[];
        });
      },
      (result) {
        final workers = result.data ?? const <PreviousWorkerModel>[];
        final availableWorkerIds = workers
            .map((worker) => worker.id)
            .whereType<int>()
            .toSet();
        final currentWorkerIds = widget.bloc.state.selectedWorkerIds;
        final retainedWorkerIds = currentWorkerIds
            .where(availableWorkerIds.contains)
            .toList(growable: false);

        setState(() {
          _status = BlocStatus.success;
          _errorMessage = null;
          _workers = workers;
        });

        if (retainedWorkerIds.length != currentWorkerIds.length) {
          widget.bloc.add(
            SetPreferredWorkersEvent(workerIds: retainedWorkerIds),
          );
          widget.onSelectedWorkersChanged(retainedWorkerIds);
        }
      },
    );
  }

  void _toggleWorker(ClMainState state, int workerId) {
    final workerIds = List<int>.from(state.selectedWorkerIds);
    if (workerIds.contains(workerId)) {
      workerIds.remove(workerId);
    } else {
      workerIds.add(workerId);
    }

    widget.bloc.add(SetPreferredWorkersEvent(workerIds: workerIds));
    widget.onSelectedWorkersChanged(workerIds);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClMainBloc, ClMainState>(
      bloc: widget.bloc,
      builder: (context, state) {
        return ClServicePreviousWorkersSectionWidget(
          workers: filterPreviousWorkersByGender(
            _workers,
            state.genderPreference,
          ),
          selectedWorkerIds: state.selectedWorkerIds,
          isLoading: _status == BlocStatus.loading,
          errorMessage: _status == BlocStatus.failed ? _errorMessage : null,
          onSelectWorker: (workerId) => _toggleWorker(state, workerId),
          onOpenWorkerProfile: (worker) {
            context.pushRoute(
              '/clworkerprofiledetail',
              arguments: WorkerProfileRouteArgs.fromPreviousWorker(worker),
            );
          },
        );
      },
    );
  }
}
