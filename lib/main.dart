import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_clone/providers/auth.dart';
import 'package:whatsapp_clone/providers/user.dart';
import 'package:whatsapp_clone/screens/auth_screen.dart';
import 'package:whatsapp_clone/screens/home.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

enum AuthMode {
  LOGGED_IN,
  LOGGED_OUT,
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProvider.value(value: User()),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primaryColor: Colors.white,
              scaffoldBackgroundColor: Hexcolor('#FFFFFF'),
              appBarTheme: AppBarTheme(
                color: Hexcolor('#075E54'),
                actionsIconTheme: IconThemeData(
                  color: Colors.white.withOpacity(0.87),
                ),
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: FutureBuilder(
              future: auth.getCurrentUser(),
              builder: (ctx, snapshot) {
                return snapshot.connectionState == ConnectionState.waiting
                    ? CircularProgressIndicator()
                    : snapshot.data == null ? AuthScreen() : Home();
              },
            ),
            // FutureBuilder(
            //     future: auth.tryAutoLogin(),
            //     builder: (ctx, snapshot) =>
            //         snapshot.connectionState == ConnectionState.waiting
            //             ? CircularProgressIndicator()
            //             : AuthScreen(),
            //   ),
            debugShowCheckedModeBanner: false,
          ),
        ));
  }
}
