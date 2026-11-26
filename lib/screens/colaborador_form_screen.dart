import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../data/models.dart';
import '../data/repositorios.dart';
import '../services/app_services.dart';
import '../widgets/comuns.dart';

class ColaboradorFormScreen extends StatefulWidget {
  /// Nulo para cadastro; preenchido para edição.
  final Colaborador? colaborador;
  const ColaboradorFormScreen({super.key, this.colaborador});

  @override
  State<ColaboradorFormScreen> createState() => _ColaboradorFormScreenState();
}

class _ColaboradorFormScreenState extends State<ColaboradorFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.colaborador?.nome);
  late final _cpf = TextEditingController(text: widget.colaborador?.cpf);
  late final _matricula = TextEditingController(
    text: widget.colaborador?.matricula,
  );
  late final _setor = TextEditingController(text: widget.colaborador?.setor);
  late final _funcao = TextEditingController(text: widget.colaborador?.funcao);
  late bool _ativo = widget.colaborador?.ativo ?? true;
  bool _salvando = false;

  bool get _editando => widget.colaborador != null;

  @override
  void dispose() {
    for (final c in [_nome, _cpf, _matricula, _setor, _funcao]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _salvando = true);
    final nav = Navigator.of(context);
    try {
      await AppServices.of(context).colaboradores.salvar(
        Colaborador(
          id: widget.colaborador?.id,
          nome: _nome.text.trim(),
          cpf: Formatos.cpf(_cpf.text),
          matricula: _matricula.text.trim(),
          setor: _setor.text.trim(),
          funcao: _funcao.text.trim(),
          ativo: _ativo,
        ),
      );
      nav.pop(true);
    } on RegraNegocioException catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarMensagem(context, e.mensagem, erro: true);
    }
  }

  String? _obrigatorio(String? v) =>
      (v ?? '').trim().isEmpty ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar colaborador' : 'Novo colaborador'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Eyebrow('Dados pessoais'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome completo'),
              validator: _obrigatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cpf,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'CPF',
                hintText: '000.000.000-00',
              ),
              validator: (v) =>
                  Formatos.cpfValido(v ?? '') ? null : 'CPF inválido',
            ),
            const SizedBox(height: 24),
            const Eyebrow('Dados funcionais'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _matricula,
              decoration: const InputDecoration(labelText: 'Matrícula'),
              validator: _obrigatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _setor,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Setor'),
              validator: _obrigatorio,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _funcao,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Função'),
              validator: _obrigatorio,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Colaborador ativo'),
              subtitle: const Text('Inativos não aparecem para novas entregas'),
              value: _ativo,
              onChanged: (v) => setState(() => _ativo = v),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_editando ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR'),
            ),
          ],
        ),
      ),
    );
  }
}
