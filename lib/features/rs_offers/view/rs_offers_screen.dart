import 'package:dllni_user_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'manager/bloc/rs_offers_bloc.dart';
import 'widget/rs_offers_view.dart';

class RsOffersScreen extends StatelessWidget {
  const RsOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RsOffersBloc>(
      lazy: false,
      create: (context) => getIt<RsOffersBloc>()..add(FetchRsOffersProductsEvent(isReload: true)),
      child: const RsOffersView(),
    );
  }
}
