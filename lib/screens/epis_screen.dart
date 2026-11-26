import 'package:material_ui/material_ui.dart';

import '../core/formatos.dart';
import '../data/models.dart';
import '../services/app_services.dart';
import '../theme/hc_theme.dart';
import '../widgets/comuns.dart';
import 'epi_form_screen.dart';
import 'home_screen.dart';

class EpisScreen extends StatefulWidget {
  final AbrirTela onAbrir;
  const EpisScreen({super.key, required this.onAbrir});

  @override
  State<EpisScreen> createState() => _EpisScreenState();
}

class _EpisScreenState extends State<EpisScreen> {
  String _busca = '';
  Future<List<Epi>>? _lista;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lista ??= _carregar();
  }

  Future<List<Epi>> _carregar() =>
      AppServices.of(context).epis.listar(busca: _busca);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar por nome ou CA',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() {
              _busca = v;
              _lista = _carregar();
            }),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Epi>>(
            future: _lista,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final lista = snap.data!;
              if (lista.isEmpty) {
                return const EstadoVazio(
                  icone: Icons.health_and_safety_outlined,
                  titulo: 'Nenhum EPI encontrado',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: lista.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _EpiCard(
                  epi: lista[i],
                  onTap: () => widget.onAbrir(EpiFormScreen(epi: lista[i])),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EpiCard extends StatelessWidget {
  final Epi epi;
  final VoidCallback onTap;
  const _EpiCard({required this.epi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final corEstoque = epi.estoque == 0
        ? HcColors.danger
        : epi.estoqueBaixo
        ? HcColors.amber
        : HcColors.success;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      epi.nome,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CA ${epi.ca} · válido até ${Formatos.data(epi.validadeCa)}\n'
                      'Troca a cada ${Formatos.periodicidade(epi.periodicidadeDias)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (epi.caVencido) ...[
                      const SizedBox(height: 6),
                      const Etiqueta('CA vencido', cor: HcColors.danger),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    '${epi.estoque}',
                    style: TextStyle(
                      fontFamily: HcFonts.headline,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: corEstoque,
                    ),
                  ),
                  const Text(
                    'EM ESTOQUE',
                    style: TextStyle(
                      fontFamily: HcFonts.label,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      letterSpacing: 0.8,
                      color: HcColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
