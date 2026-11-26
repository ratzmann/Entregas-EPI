import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../data/repositorios.dart';
import '../services/app_services.dart';
import '../widgets/comuns.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _salvando = true);
    final nav = Navigator.of(context);
    try {
      await AppServices.of(context).sessao
          .cadastrarEEntrar(_nome.text, _email.text, _senha.text);
      // A sessão mudou: volta à raiz, que agora mostra a área logada.
      nav.popUntil((r) => r.isFirst);
    } on RegraNegocioException catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarMensagem(context, e.mensagem, erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar acesso')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Eyebrow('Novo usuário'),
            const SizedBox(height: 6),
            Text(
              'Cadastre o responsável pelas entregas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome completo'),
              validator: (v) =>
                  (v ?? '').trim().length < 3 ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (v) => Formatos.emailValido(v ?? '')
                  ? null
                  : 'Informe um e-mail válido',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _senha,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                helperText: 'Mínimo de 6 caracteres',
              ),
              validator: (v) => (v ?? '').length < 6
                  ? 'A senha precisa de 6 caracteres'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar senha'),
              validator: (v) =>
                  v != _senha.text ? 'As senhas não conferem' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: const Text('CRIAR E ENTRAR'),
            ),
          ],
        ),
      ),
    );
  }
}
