import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_template/core/widgets/app_loader.dart';
import 'package:firebase_template/features/auth/presentation/pages/sign_in_page.dart';
import 'package:firebase_template/features/auth/presentation/providers/auth_providers.dart';
import 'package:firebase_template/features/notes/presentation/pages/notes_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const SignInPage();
        }
        return NotesPage(userId: user.id, userEmail: user.email);
      },
      loading: () => const Scaffold(body: AppLoader()),
      error: (_, _) => const Scaffold(
        body: Center(child: Text('Failed to resolve authentication state.')),
      ),
    );
  }
}
