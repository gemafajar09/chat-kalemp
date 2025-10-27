import 'package:chatai/router/routers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("file ENV tidak ditemukan atau tidak terbaca: $e");
  }

  final apiKey = dotenv.env["API_KEY"];
  final appId = dotenv.env["APP_ID"];
  final senderId = dotenv.env["SENDER_ID"];
  final projectId = dotenv.env["PROJECT_ID"];

  if ([apiKey, appId, senderId, projectId].contains(null)) {
    debugPrint("silahkan cek variable di dalam file .env apakah sudah banar!");
  }

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey.toString(),
      appId: appId.toString(),
      messagingSenderId: senderId.toString(),
      projectId: projectId.toString(),
    ),
  );

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(gorouter);
    return MaterialApp.router(
      title: 'Belajar Chat AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}
