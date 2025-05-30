import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'store/reducers/app_reducer.dart';
import 'store/app_state.dart';
import 'screens/home/home_screen.dart';
import 'package:shiftsmart/screens/payslips/payslip_import_screen.dart';
import 'store/middleware/auth_middleware.dart'; // Include auth middleware
import 'firebase_options.dart'; // Generated Firebase configuration
import 'screens/auth/login.dart'; // Login screen route
import 'screens/auth/register.dart'; // Registration screen route

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with CLI-generated options for each platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Initialize with platform-specific config
  );

  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [authMiddleware], // Apply authentication middleware
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
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ], // Localization delegates for internationalization support
        supportedLocales: const [
          Locale('en', ''),
          Locale('nb', ''),
          Locale('nn', ''),
        ], // Supported locales for the app
        //home: HomeScreen(),
        initialRoute: LoginScreen.routeName, 
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(),         // Login screen route
          RegisterScreen.routeName: (context) => RegisterScreen(),   // Register screen route
          '/scanPayslip': (context) => PayslipImportScreen(),
        },
      ),
    );
  }
}
