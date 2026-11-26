import 'package:material_ui/material_ui.dart';

import '../data/models.dart';
import '../services/app_services.dart';
import '../widgets/comuns.dart';
import '../widgets/entrega_tile.dart';
import 'entrega_detalhe_screen.dart';
import 'home_screen.dart';

class EntregasScreen extends StatefulWidget {
  final AbrirTela onAbrir;
  const EntregasScreen({super.key, required this.onAbrir});

  @override
  State<EntregasScreen> createState() => _EntregasScreenState();
}

class _EntregasScreenState extends State<EntregasScreen> {
  String _busca = '';
  Future<List<Entrega>>? _entregas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _entregas ??= _carregar();
  }

  Future<List<Entrega>> _carregar() =>
      AppServices.of(context).entregas.listar(busca: _busca);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar por colaborador',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() {
              _busca = v;
              _entregas = _carregar();
            }),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Entrega>>(
            future: _entregas,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final lista = snap.data!;
              if (lista.isEmpty) {
                return EstadoVazio(
                  icone: Icons.assignment_outlined,
                  titulo: _busca.isEmpty
                      ? 'Nenhuma entrega registrada'
                      : 'Nenhuma entrega encontrada',
                  mensagem: _busca.isEmpty
                      ? 'Use o botão "Nova entrega" para registrar a primeira.'
                      : null,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: lista.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => EntregaTile(
                  entrega: lista[i],
                  onTap: () => widget.onAbrir(
                    EntregaDetalheScreen(entregaId: lista[i].id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
