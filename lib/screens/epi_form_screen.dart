import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../data/models.dart';
import '../data/repositorios.dart';
import '../services/app_services.dart';
import '../widgets/comuns.dart';

class EpiFormScreen extends StatefulWidget {
  final Epi? epi;
  const EpiFormScreen({super.key, this.epi});

  @override
  State<EpiFormScreen> createState() => _EpiFormScreenState();
}

class _EpiFormScreenState extends State<EpiFormScreen> {
  static const _periodicidades = {
    7: '7 dias',
    15: '15 dias',
    30: '1 mês',
    90: '3 meses',
    180: '6 meses',
    365: '1 ano',
    730: '2 anos',
  };

  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.epi?.nome);
  late final _ca = TextEditingController(text: widget.epi?.ca);
  late final _estoque = TextEditingController(
    text: widget.epi?.estoque.toString() ?? '0',
  );
  late DateTime? _validade = widget.epi?.validadeCa;
  late int _periodicidade = widget.epi?.periodicidadeDias ?? 30;
  bool _salvando = false;

  bool get _editando => widget.epi != null;

  @override
  void dispose() {
    _nome.dispose();
    _ca.dispose();
    _estoque.dispose();
    super.dispose();
  }

  Future<void> _escolherValidade() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _validade ?? hoje.add(const Duration(days: 365)),
      firstDate: DateTime(hoje.year - 5),
      lastDate: DateTime(hoje.year + 10),
      helpText: 'Validade do CA',
    );
    if (d != null) setState(() => _validade = d);
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    if (_validade == null) {
      mostrarMensagem(context, 'Informe a validade do CA.', erro: true);
      return;
    }
    setState(() => _salvando = true);
    await AppServices.of(context).epis.salvar(
      Epi(
        id: widget.epi?.id,
        nome: _nome.text.trim(),
        ca: _ca.text.trim(),
        validadeCa: _validade!,
        estoque: int.parse(_estoque.text),
        periodicidadeDias: _periodicidade,
      ),
    );
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _excluir() async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir EPI?'),
        content: Text('"${widget.epi!.nome}" será removido do catálogo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirma != true || !mounted) return;
    try {
      await AppServices.of(context).epis.excluir(widget.epi!.id!);
      if (mounted) Navigator.of(context).pop(true);
    } on RegraNegocioException catch (e) {
      if (mounted) mostrarMensagem(context, e.mensagem, erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodicidades = {..._periodicidades};
    periodicidades.putIfAbsent(
      _periodicidade,
      () => Formatos.periodicidade(_periodicidade),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar EPI' : 'Novo EPI'),
        actions: [
          if (_editando)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: _excluir,
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Eyebrow('Equipamento'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome do EPI',
                hintText: 'Ex.: Luva de raspa',
              ),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ca,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nº do CA',
                helperText:
                    'Certificado de Aprovação do Ministério do Trabalho',
              ),
              validator: (v) => RegExp(r'^\d{1,6}$').hasMatch((v ?? '').trim())
                  ? null
                  : 'CA inválido',
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _escolherValidade,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Validade do CA',
                  prefixIcon: Icon(Icons.event),
                ),
                child: Text(
                  _validade == null ? 'Selecionar' : Formatos.data(_validade!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Eyebrow('Controle'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _estoque,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade em estoque',
              ),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                return n == null || n < 0 ? 'Informe um número válido' : null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _periodicidade,
              decoration: const InputDecoration(
                labelText: 'Periodicidade de troca',
              ),
              items: [
                for (final e in periodicidades.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => _periodicidade = v!),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_editando ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR EPI'),
            ),
          ],
        ),
      ),
    );
  }
}
