import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:i_stock_mobile/cubits/login_cubit.dart';
import 'package:i_stock_mobile/repositories/device_authenticator.dart';
import 'package:i_stock_mobile/repositories/login_repository.dart';
import 'package:i_stock_mobile/repositories/session_store.dart';
import 'package:i_stock_mobile/views/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => RepositoryProvider<LoginRepositoryImpl>(
    create: (_) => LoginRepositoryImpl(
      baseUri: Uri.tryParse(dotenv.env['ISTOCK_API_BASE_URL'] ?? '') ?? Uri(),
    ),
    dispose: (repository) => repository.close(),
    child: BlocProvider<LoginCubit>(
      create: (context) => LoginCubit(
        context.read<LoginRepositoryImpl>(),
        SecureSessionStore(const FlutterSecureStorage()),
        NativeDeviceAuthenticator(LocalAuthentication()),
      ),
      child: _buildApp(),
    ),
  );

  Widget _buildApp() => MaterialApp(
    title: 'I-Stock Mobile',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF34458F)),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
    ),
    home: const LoginPage(),
  );
}
