import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'store/reducers/app_reducer.dart';
import 'store/app_state.dart';
import 'screens/home/home_screen.dart';
import 'package:shiftsmart/screens/payslips/payslip_import_screen.dart';

void main() {
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
  );

  runApp(ShiftSmartApp(store: store));
}

class ShiftSmartApp extends StatelessWidget {
  final Store<AppState> store;

  ShiftSmartApp({required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'ShiftSmart',
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: HomeScreen(),
        routes: {
          '/scanPayslip': (context) => PayslipImportScreen(),
        },
      ),
    );
  }
}
