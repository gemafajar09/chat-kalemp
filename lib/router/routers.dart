
import 'dart:async';

import 'package:chatai/page/auth/login_screen.dart';
import 'package:chatai/page/auth/register_screen.dart';
import 'package:chatai/page/dashboard/home_screen.dart';
import 'package:chatai/page/dashboard/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/legacy.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final gorouter = StateProvider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  );

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileScreen(),
      )
    ],
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;

      // rute login & register
      final loggingIn = state.uri.toString() == '/login';
      final registering = state.uri.toString() == '/register';

      if (user == null) {
        if (loggingIn || registering) return null;
        return '/login';
      }

      if (loggingIn || registering) return '/';

      return null;
    },
    errorPageBuilder: (context, state) {
      return MaterialPage(
          child: Scaffold(
            body: Center(
              child: Text("Halaman Tidak Ditemuakn"),
            ),
          )
      );
    }
  );
});