import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_stock_mobile/cubits/login_cubit.dart';
import 'package:i_stock_mobile/views/login_page.dart';

/// Temporary destination after a successful login.
class PastillesPlaceholderPage extends StatelessWidget {
  const PastillesPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I-STOCK'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<LoginCubit>().signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              );
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
    );
  }
}
