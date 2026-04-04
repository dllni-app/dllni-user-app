import 'package:dllni_user_app/core/di/injection.dart';
import 'package:dllni_user_app/features/rs_favourite/domain/usecases/fetch_rs_favourites_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../manager/bloc/rs_favourite_bloc.dart';
import '../widgets/rs_favourite_view.dart';

class RsFavouriteScreen extends StatelessWidget {
  const RsFavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RsFavouriteBloc>(
      lazy: false,
      create: (context) => getIt<RsFavouriteBloc>()..add(FetchRsFavouritesEvent(params: FetchRsFavouritesParams(page: 1), isReload: true)),
      child: const RsFavouriteView(),
    );
  }
}
