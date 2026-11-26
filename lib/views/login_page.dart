import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i_stock_mobile/cubits/login_cubit.dart';
import 'package:i_stock_mobile/states/login_state.dart';
import 'package:i_stock_mobile/views/pastilles_placeholder_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF34458F);
    const graphite = Color(0xFF252B35);
    const muted = Color(0xFF727B8B);
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginLoaded) {
          _passwordController.clear();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const PastillesPlaceholderPage(),
            ),
          );
        }
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final isLoading = state is LoginLoading;
          final error = state is LoginError ? state : null;
          return Scaffold(
            body: SafeArea(
              top: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: blue,
                      padding: EdgeInsets.fromLTRB(
                        24,
                        MediaQuery.paddingOf(context).top + 48,
                        24,
                        52,
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DDA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'I-STOCK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Seu estoque.\nSempre sob controle.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Acesse sua conta',
                            style: TextStyle(
                              color: graphite,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Use suas credenciais do I-STOCK.',
                            style: TextStyle(color: muted, fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'E-mail',
                            style: TextStyle(
                              color: graphite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Semantics(
                            label: 'E-mail',
                            child: TextField(
                              controller: _emailController,
                              enabled: !isLoading,
                              onChanged: context
                                  .read<LoginCubit>()
                                  .emailChanged,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: InputDecoration(
                                hintText: 'seu@email.com',
                                border: const OutlineInputBorder(),
                                errorText: error?.emailError,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Senha',
                            style: TextStyle(
                              color: graphite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Semantics(
                            label: 'Senha',
                            child: TextField(
                              controller: _passwordController,
                              enabled: !isLoading,
                              onChanged: context
                                  .read<LoginCubit>()
                                  .passwordChanged,
                              obscureText: !state.isPasswordVisible,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                errorText: error?.passwordError,
                                suffixIcon: IconButton(
                                  tooltip: state.isPasswordVisible
                                      ? 'Ocultar senha'
                                      : 'Mostrar senha',
                                  onPressed: isLoading
                                      ? null
                                      : context
                                            .read<LoginCubit>()
                                            .togglePasswordVisibility,
                                  icon: Icon(
                                    state.isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (error?.message != null) ...[
                            const SizedBox(height: 12),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                error!.message!,
                                style: const TextStyle(
                                  color: Color(0xFFB43B42),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: isLoading
                                  ? null
                                  : context.read<LoginCubit>().submit,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Entrar'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'ou',
                                  style: TextStyle(color: muted),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.fingerprint),
                              label: const Text('Desbloquear com biometria'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Para uma sessão salva ainda válida. Se expirar, entre com e-mail e senha.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                          const SizedBox(height: 24),
                          const Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Icon(Icons.lock_outline, size: 14, color: muted),
                              Text(
                                'Acesso seguro ao seu estoque',
                                style: TextStyle(color: muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
