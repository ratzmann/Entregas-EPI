import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../data/models.dart';
import '../services/app_services.dart';
import '../theme/hc_theme.dart';
import '../widgets/comuns.dart';

/// Comprovante da entrega: itens, CA de cada EPI, próxima troca e assinatura.
class EntregaDetalheScreen extends StatefulWidget {
  final int entregaId;
  const EntregaDetalheScreen({super.key, required this.entregaId});

  @override
  State<EntregaDetalheScreen> createState() => _EntregaDetalheScreenState();
}

class _EntregaDetalheScreenState extends State<EntregaDetalheScreen> {
  Future<Entrega?>? _entrega;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _entrega ??= AppServices.of(context).entregas.porId(widget.entregaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entrega nº ${widget.entregaId}')),
      body: FutureBuilder<Entrega?>(
        future: _entrega,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final e = snap.data;
          if (e == null) {
            return const EstadoVazio(
              icone: Icons.search_off,
              titulo: 'Entrega não encontrada',
            );
          }
          final texto = Theme.of(context).textTheme;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Eyebrow('Colaborador'),
                      const SizedBox(height: 4),
                      Text(e.colaboradorNome, style: texto.titleLarge),
                      Text(e.colaboradorSetor, style: texto.bodySmall),
                      const SizedBox(height: 14),
                      _Linha(Icons.event, 'Data', Formatos.dataHora(e.data)),
                      _Linha(
                        Icons.badge_outlined,
                        'Responsável',
                        e.responsavelNome,
                      ),
                      if (e.observacao.isNotEmpty)
                        _Linha(Icons.notes, 'Observação', e.observacao),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Eyebrow('EPIs entregues · ${e.totalItens}'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (final i in e.itens) ...[
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: HcColors.surface2,
                          child: Text(
                            '${i.quantidade}×',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: HcColors.ink,
                            ),
                          ),
                        ),
                        title: Text(i.epiNome),
                        subtitle: Text(
                          'CA ${i.epiCa} · próxima troca em '
                          '${Formatos.data(e.data.add(Duration(days: i.periodicidadeDias)))}',
                        ),
                      ),
                      if (i != e.itens.last) const Divider(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Eyebrow('Assinatura do colaborador'),
              const SizedBox(height: 8),
              Card(
                clipBehavior: Clip.antiAlias,
                child: e.assinatura == null
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Entrega registrada sem assinatura.'),
                      )
                    : Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                        child: Image.memory(e.assinatura!, height: 150),
                      ),
              ),
              const SizedBox(height: 12),
              Text(
                'Declaro ter recebido os EPIs acima, gratuitamente, e ter sido '
                'orientado sobre seu uso, guarda e conservação (NR-6).',
                style: texto.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;
  const _Linha(this.icone, this.rotulo, this.valor);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 18, color: HcColors.inkMuted),
        const SizedBox(width: 10),
        SizedBox(
          width: 96,
          child: Text(
            rotulo,
            style: const TextStyle(color: HcColors.inkMuted, fontSize: 13.5),
          ),
        ),
        Expanded(child: Text(valor)),
      ],
    ),
  );
}
