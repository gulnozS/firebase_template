import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_template/core/di/app_providers.dart';
import 'package:firebase_template/core/routing/go_router_refresh_stream.dart';
import 'package:firebase_template/features/auth/presentation/pages/sign_in_page.dart';
import 'package:firebase_template/features/notes/presentation/pages/notes_page.dart';

/// Centralized route path constants to prevent typos.
class AppRoutes {
  AppRoutes._();

  static const signIn = '/signin';
  static const notes = '/notes';
}

/// Router provider with auth-aware redirect rules.
///
/// Redirect rules:
/// - Signed-out users are always sent to `/signin`.
/// - Signed-in users are blocked from `/signin` and sent to `/notes`.
final appRouterProvider = Provider<GoRouter>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final refresh = GoRouterRefreshStream(firebaseAuth.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.notes,
    refreshListenable: refresh,
    redirect: (context, state) {
      final isSignedIn = firebaseAuth.currentUser != null;
      final isOnSignIn = state.matchedLocation == AppRoutes.signIn;

      if (!isSignedIn && !isOnSignIn) {
        return AppRoutes.signIn;
      }
      if (isSignedIn && isOnSignIn) {
        return AppRoutes.notes;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.notes,
        builder: (context, state) {
          final user = firebaseAuth.currentUser;
          if (user == null) {
            return const SizedBox.shrink();
          }
          return NotesPage(userId: user.uid, userEmail: user.email ?? '');
        },
      ),
    ],
  );
});
