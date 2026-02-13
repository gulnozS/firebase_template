import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_template/app.dart';
import 'package:firebase_template/core/config/firebase_runtime_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseRuntimeOptions.currentPlatform);
  runApp(const ProviderScope(child: App()));
}
