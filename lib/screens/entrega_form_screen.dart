import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../data/models.dart';
import '../data/repositorios.dart';
import '../services/app_services.dart';
import '../theme/hc_theme.dart';
import '../widgets/assinatura_pad.dart';
import '../widgets/comuns.dart';

/// Registro de entrega de EPI: colaborador, itens, data e assinatura.
class EntregaFormScreen extends StatefulWidget {
  /// Pré-seleciona o colaborador quando aberta a partir da ficha dele.
  final int? colaboradorId;
  const EntregaFormScreen({super.key, this.colaboradorId});

  @override
  State<EntregaFormScreen> createState() => _EntregaFormScreenState();
}

class _EntregaFormScreenState extends State<EntregaFormScreen> {
  final _form = GlobalKey<FormState>();
  final _observacao = TextEditingController();
  final _assinatura = AssinaturaController();
  final Map<int, int> _quantidades = {};

  Future<(List<Colaborador>, List<Epi>)>? _dados;
  int? _colaboradorId;
  DateTime _data = DateTime.now();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _colaboradorId = widget.colaboradorId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dados ??= _carregar();
  }

  Future<(List<Colaborador>, List<Epi>)> _carregar() async {
    final s = AppServices.of(context);
    return (
      await s.colaboradores.listar(somenteAtivos: true),
      await s.epis.listar(),
    );
  }

  @override
  void dispose() {
    _observacao.dispose();
    _assinatura.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: hoje.subtract(const Duration(days: 365)),
      lastDate: hoje,
    );
    if (escolhida == null) return;
    setState(
      () => _data = DateTime(
        escolhida.year,
        escolhida.month,
        escolhida.day,
        _data.hour,
        _data.minute,
      ),
    );
  }

  void _alterarQuantidade(Epi epi, int delta) {
    setState(() {
      final nova = (_quantidades[epi.id!] ?? 0) + delta;
      if (nova <= 0) {
        _quantidades.remove(epi.id!);
      } else if (nova <= epi.estoque) {
        _quantidades[epi.id!] = nova;
      }
    });
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    if (_quantidades.isEmpty) {
      mostrarMensagem(context, 'Selecione ao menos um EPI.', erro: true);
      return;
    }
    if (_assinatura.vazia) {
      mostrarMensagem(
        context,
        'Peça ao colaborador para assinar o recebimento.',
        erro: true,
      );
      return;
    }
    setState(() => _salvando = true);
    final s = AppServices.of(context);
    final nav = Navigator.of(context);
    try {
      await s.entregas.registrar(
        NovaEntrega(
          colaboradorId: _colaboradorId!,
          usuarioId: s.sessao.usuario!.id!,
          data: _data,
          observacao: _observacao.text,
          quantidadePorEpi: Map.of(_quantidades),
          assinatura: await _assinatura.exportarPng(),
        ),
      );
      if (!mounted) return;
      mostrarMensagem(context, 'Entrega registrada com sucesso.');
      nav.pop(true);
    } on RegraNegocioException catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      mostrarMensagem(context, e.mensagem, erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova entrega')),
      body: FutureBuilder<(List<Colaborador>, List<Epi>)>(
        future: _dados,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final (colaboradores, epis) = snap.data!;
          if (colaboradores.isEmpty || epis.isEmpty) {
            return EstadoVazio(
              icone: Icons.info_outline,
              titulo: colaboradores.isEmpty
                  ? 'Cadastre um colaborador ativo primeiro'
                  : 'Cadastre ao menos um EPI primeiro',
            );
          }
          if (!colaboradores.any((c) => c.id == _colaboradorId)) {
            _colaboradorId = null;
          }
          final totalItens = _quantidades.values.fold(0, (a, b) => a + b);

          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Eyebrow('1 · Colaborador'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _colaboradorId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Selecione o colaborador',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: [
                    for (final c in colaboradores)
                      DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          '${c.nome} · ${c.setor}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => _colaboradorId = v),
                  validator: (v) =>
                      v == null ? 'Selecione o colaborador' : null,
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _escolherData,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data da entrega',
                      prefixIcon: Icon(Icons.event),
                    ),
                    child: Text(Formatos.data(_data)),
                  ),
                ),
                const SizedBox(height: 24),
                Eyebrow(
                  totalItens == 0
                      ? '2 · EPIs entregues'
                      : '2 · EPIs entregues · $totalItens selecionado(s)',
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      for (final epi in epis) ...[
                        _LinhaEpi(
                          epi: epi,
                          quantidade: _quantidades[epi.id] ?? 0,
                          onAlterar: (d) => _alterarQuantidade(epi, d),
                        ),
                        if (epi != epis.last) const Divider(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacao,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                    hintText: 'Ex.: substituição por desgaste',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Eyebrow('3 · Assinatura do colaborador'),
                    ),
                    TextButton.icon(
                      onPressed: _assinatura.limpar,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Limpar'),
                    ),
                  ],
                ),
                AssinaturaPad(controller: _assinatura),
                const SizedBox(height: 8),
                Text(
                  'Ao assinar, o colaborador declara ter recebido os EPIs e as '
                  'orientações de uso, guarda e conservação (NR-6).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: const Icon(Icons.check),
                  label: const Text('REGISTRAR ENTREGA'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LinhaEpi extends StatelessWidget {
  final Epi epi;
  final int quantidade;
  final ValueChanged<int> onAlterar;

  const _LinhaEpi({
    required this.epi,
    required this.quantidade,
    required this.onAlterar,
  });

  @override
  Widget build(BuildContext context) {
    // NR-6: EPI com CA vencido não pode ser entregue.
    final bloqueado = epi.caVencido || epi.estoque == 0;
    final motivo = epi.caVencido
        ? 'CA vencido'
        : epi.estoque == 0
        ? 'Sem estoque'
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  epi.nome,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: bloqueado ? HcColors.inkMuted : HcColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'CA ${epi.ca} · estoque ${epi.estoque}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (motivo != null) ...[
                      const SizedBox(width: 6),
                      Etiqueta(motivo, cor: HcColors.danger),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (!bloqueado) ...[
            IconButton(
              tooltip: 'Diminuir',
              onPressed: quantidade > 0 ? () => onAlterar(-1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            SizedBox(
              width: 24,
              child: Text(
                '$quantidade',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: HcFonts.headline,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Aumentar',
              color: HcColors.brandInk,
              onPressed: quantidade < epi.estoque ? () => onAlterar(1) : null,
              icon: const Icon(Icons.add_circle),
            ),
          ],
        ],
      ),
    );
  }
}
