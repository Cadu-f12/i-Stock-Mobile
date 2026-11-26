import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_stock_mobile/cubits/login_cubit.dart';
import 'package:i_stock_mobile/states/login_state.dart';
import 'package:i_stock_mobile/views/login_page.dart';

/// Temporary destination after a successful login.
class PastillesPlaceholderPage extends StatelessWidget {
  const PastillesPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          previous is LoginLoaded && current is LoginInitial,
      listener: (context, state) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('I-STOCK'),
          actions: [
            IconButton(
              tooltip: 'Bloquear',
              icon: const Icon(Icons.lock_outline),
              onPressed: () => context.read<LoginCubit>().lock(),
            ),
            IconButton(
              tooltip: 'Sair',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                try {
                  await context.read<LoginCubit>().signOut();
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Não foi possível apagar a sessão salva. Tente sair novamente.',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Pastilles — próxima etapa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
