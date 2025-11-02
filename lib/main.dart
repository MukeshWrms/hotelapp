import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myhotx/cubit/cubit_auto.dart';
import 'package:myhotx/cubit/cubit_hotel.dart';
import 'package:myhotx/cubit/cubit_search_hotel.dart';

import 'package:myhotx/ui/hotel2.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyHotXApp());
}

class MyHotXApp extends StatelessWidget {
  const MyHotXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => HotalListCubit(context: context)),
        BlocProvider(create: (_) => AutoSearchListCubit(context: context)),
        BlocProvider(create: (_) => HotalSearchListCubit(context: context)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        home: DashboardScreenX(),
      ),
    );
  }
}
