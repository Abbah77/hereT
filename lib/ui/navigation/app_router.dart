import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_first_app/ui/screens/auth/login_screen.dart';
import 'package:offline_first_app/ui/screens/auth/register_screen.dart';
import 'package:offline_first_app/ui/screens/home/home_screen.dart';
import 'package:offline_first_app/ui/screens/create_post/create_post_screen.dart';
import 'package:offline_first_app/ui/screens/profile/profile_screen.dart';

class AppRouter {
  static GoRouter router(bool isLoggedIn) {
    return GoRouter(
      initialLocation: isLoggedIn ? '/home' : '/login',
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/create-post',
          name: 'create-post',
          builder: (context, state) => const CreatePostScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    );
  }
}