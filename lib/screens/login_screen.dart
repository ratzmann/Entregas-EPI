import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../services/app_services.dart';
import '../theme/hc_theme.dart';
import '../widgets/comuns.dart';
import 'cadastro_usuario_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _ocultarSenha = true;
  bool _carregando = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _carregando = true);
    final ok = await AppServices.of(context).sessao
        .entrar(_email.text, _senha.text);
    if (!mounted) return;
    setState(() => _carregando = false);
    if (!ok) {
      mostrarMensagem(context, 'E-mail ou senha incorretos.', erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HcColors.navy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: HcLogo(altura: 56, sobreEscuro: true)),
                  const SizedBox(height: 36),
                  const Eyebrow('Controle de EPI', cor: HcColors.brand),
                  const SizedBox(height: 8),
                  Text(
                    'Entregas registradas, colaboradores protegidos.',
                    style: Theme.of(context).textTheme.headlineSmall!
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                              validator: (v) => Formatos.emailValido(v ?? '')
                                  ? null
                                  : 'Informe um e-mail válido',
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _senha,
                              obscureText: _ocultarSenha,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _entrar(),
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _ocultarSenha
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  icon: Icon(
                                    _ocultarSenha
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(
                                    () => _ocultarSenha = !_ocultarSenha,
                                  ),
                                ),
                              ),
                              validator: (v) =>
                                  (v ?? '').isEmpty ? 'Informe a senha' : null,
                            ),
                            const SizedBox(height: 22),
                            FilledButton(
                              onPressed: _carregando ? null : _entrar,
                              child: _carregando
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('ENTRAR'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CadastroUsuarioScreen(),
                                ),
                              ),
                              child: const Text('Não tem conta? Criar acesso'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Acesso de demonstração: admin@hc.com · hc123456',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9FB7C6), fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
