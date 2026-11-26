import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../data/models.dart';
import '../services/app_services.dart';
import '../theme/hc_theme.dart';
import '../widgets/comuns.dart';
import '../widgets/entrega_tile.dart';
import 'colaborador_detalhe_screen.dart';
import 'entrega_detalhe_screen.dart';
import 'home_screen.dart';

class _DadosPainel {
  final int entregasMes;
  final int colaboradoresAtivos;
  final List<Epi> epis;
  final List<TrocaPrevista> trocas;
  final List<Entrega> ultimas;

  _DadosPainel(
    this.entregasMes,
    this.colaboradoresAtivos,
    this.epis,
    this.trocas,
    this.ultimas,
  );
}

class PainelScreen extends StatefulWidget {
  final AbrirTela onAbrir;
  final ValueChanged<int> onIrPara;

  const PainelScreen({
    super.key,
    required this.onAbrir,
    required this.onIrPara,
  });

  @override
  State<PainelScreen> createState() => _PainelScreenState();
}

class _PainelScreenState extends State<PainelScreen> {
  late Future<_DadosPainel> _dados;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dados = _carregar();
  }

  Future<_DadosPainel> _carregar() async {
    final s = AppServices.of(context);
    final agora = DateTime.now();
    final r = await Future.wait([
      s.entregas.contarDesde(DateTime(agora.year, agora.month)),
      s.colaboradores.contarAtivos(),
      s.epis.listar(),
      s.entregas.trocasPrevistas(),
      s.entregas.listar(limite: 5),
    ]);
    return _DadosPainel(
      r[0] as int,
      r[1] as int,
      r[2] as List<Epi>,
      r[3] as List<TrocaPrevista>,
      r[4] as List<Entrega>,
    );
  }

  Future<void> _recarregar() async {
    final f = _carregar();
    setState(() => _dados = f);
    await f;
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AppServices.of(context).sessao.usuario!;
    return FutureBuilder<_DadosPainel>(
      future: _dados,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final d = snap.data!;
        final estoqueBaixo = d.epis.where((e) => e.estoqueBaixo).length;
        final caVencido = d.epis.where((e) => e.caVencido).length;
        return RefreshIndicator(
          onRefresh: _recarregar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
            children: [
              const Eyebrow('Segurança do trabalho'),
              const SizedBox(height: 4),
              Text(
                'Olá, ${usuario.nome.split(' ').first}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.6,
                children: [
                  _Indicador(
                    'Entregas no mês',
                    '${d.entregasMes}',
                    Icons.assignment_turned_in_outlined,
                    HcColors.brandInk,
                    onTap: () => widget.onIrPara(1),
                  ),
                  _Indicador(
                    'Colaboradores ativos',
                    '${d.colaboradoresAtivos}',
                    Icons.groups_outlined,
                    HcColors.brandInk,
                    onTap: () => widget.onIrPara(2),
                  ),
                  _Indicador(
                    'EPIs com estoque baixo',
                    '$estoqueBaixo',
                    Icons.inventory_2_outlined,
                    estoqueBaixo > 0 ? HcColors.amber : HcColors.success,
                    onTap: () => widget.onIrPara(3),
                  ),
                  _Indicador(
                    'CAs vencidos',
                    '$caVencido',
                    Icons.verified_outlined,
                    caVencido > 0 ? HcColors.danger : HcColors.success,
                    onTap: () => widget.onIrPara(3),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Eyebrow('Trocas previstas · próximos 15 dias'),
              const SizedBox(height: 8),
              if (d.trocas.isEmpty)
                const _CardTexto('Nenhuma troca de EPI vencida ou próxima.')
              else
                Card(
                  child: Column(
                    children: [
                      for (final t in d.trocas.take(6)) ...[
                        ListTile(
                          leading: Icon(
                            t.vencida ? Icons.error_outline : Icons.schedule,
                            color: t.vencida ? HcColors.danger : HcColors.amber,
                          ),
                          title: Text(t.colaboradorNome),
                          subtitle: Text(t.epiNome),
                          trailing: Text(
                            t.vencida
                                ? 'Venceu\n${Formatos.data(t.vencimento)}'
                                : 'Vence\n${Formatos.data(t.vencimento)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: t.vencida
                                  ? HcColors.danger
                                  : HcColors.inkMuted,
                            ),
                          ),
                          onTap: () => widget.onAbrir(
                            ColaboradorDetalheScreen(
                              colaboradorId: t.colaboradorId,
                            ),
                          ),
                        ),
                        if (t != d.trocas.take(6).last) const Divider(),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Eyebrow('Últimas entregas')),
                  TextButton(
                    onPressed: () => widget.onIrPara(1),
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              if (d.ultimas.isEmpty)
                const _CardTexto(
                  'Nenhuma entrega registrada ainda. Toque em "Nova entrega" para começar.',
                )
              else
                for (final e in d.ultimas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EntregaTile(
                      entrega: e,
                      onTap: () =>
                          widget.onAbrir(EntregaDetalheScreen(entregaId: e.id)),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _Indicador extends StatelessWidget {
  final String rotulo;
  final String valor;
  final IconData icone;
  final Color cor;
  final VoidCallback onTap;

  const _Indicador(
    this.rotulo,
    this.valor,
    this.icone,
    this.cor, {
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontFamily: HcFonts.headline,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1,
                  ),
                ),
                const Spacer(),
                Icon(icone, color: cor, size: 22),
              ],
            ),
            Text(
              rotulo,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 12.5,
                color: HcColors.inkMuted,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CardTexto extends StatelessWidget {
  final String texto;
  const _CardTexto(this.texto);

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(texto, style: Theme.of(context).textTheme.bodySmall),
    ),
  );
}
