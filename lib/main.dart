import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import './screens/home_screen.dart';
import './screens/new_transaction.dart';
import './models/transaction.dart';
import './screens/party_list_screen.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => Transactions(),
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Money Tracker',
            theme: ThemeData(
              // Primary brand color
              primaryColor: const Color(0xFFA80852),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFA80852),
                secondary: const Color(0xFF4C6FFF), // subtle blue accent
              ),
              scaffoldBackgroundColor: const Color(0xFFF1F2F4),
              fontFamily: 'Quicksand',
              textTheme: ThemeData.light().textTheme.copyWith(
                    headlineLarge: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 18,
                      color:
                          Color(0xFF1D2125), // dark grey instead of pure black
                      fontWeight: FontWeight.bold,
                    ),
                    labelLarge: const TextStyle(
                      color: Color(0xFF1D2125),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFF1D2125)),
                titleTextStyle: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 24,
                  color: Color(0xFF1D2125),
                ),
              ),
            ),
            routes: {
              HomeScreen.routeName: (_) => HomeScreen(),
              NewTransaction.routeName: (_) => NewTransaction(),
              PartyListScreen.routeName: (_) => const PartyListScreen(),
            },
          );
        });
  }
}
