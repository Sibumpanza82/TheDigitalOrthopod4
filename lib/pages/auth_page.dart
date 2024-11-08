import 'package:ankleromapp/pages/home_page.dart';
import 'package:ankleromapp/pages/login.dart';
import 'package:ankleromapp/pages/login_or_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
        //user is logged in
        if (snapshot.hasData){
          return HomePage();
        }else {
          //user is NOT logged in
          return LoginOrRegisterPage();
        }
        },
    ),
    );
  }
}
