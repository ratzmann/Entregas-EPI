import 'package:material_ui/material_ui.dart';

import '../data/models.dart';
import '../services/app_services.dart';
import '../theme/hc_theme.dart';
import '../widgets/comuns.dart';
import 'colaborador_detalhe_screen.dart';
import 'home_screen.dart';

class ColaboradoresScreen extends StatefulWidget {
  final AbrirTela onAbrir;
  const ColaboradoresScreen({super.key, required this.onAbrir});

  @override
  State<ColaboradoresScreen> createState() => _ColaboradoresScreenState();
}

class _ColaboradoresScreenState extends State<ColaboradoresScreen> {
  String _busca = '';
  Future<List<Colaborador>>? _lista;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lista ??= _carregar();
  }

  Future<List<Colaborador>> _carregar() =>
      AppServices.of(context).colaboradores.listar(busca: _busca);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar por nome, matrícula ou setor',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() {
              _busca = v;
              _lista = _carregar();
            }),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Colaborador>>(
            future: _lista,
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final lista = snap.data!;
              if (lista.isEmpty) {
                return const EstadoVazio(
                  icone: Icons.groups_outlined,
                  titulo: 'Nenhum colaborador encontrado',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: lista.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final c = lista[i];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: AvatarIniciais(c.iniciais, ativo: c.ativo),
                      title: Text(
                        c.nome,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: c.ativo ? HcColors.ink : HcColors.inkMuted,
                        ),
                      ),
                      subtitle: Text(
                        '${c.funcao} · ${c.setor}\nMatrícula ${c.matricula}',
                      ),
                      isThreeLine: true,
                      trailing: c.ativo
                          ? const Icon(Icons.chevron_right)
                          : const Etiqueta('Inativo', cor: HcColors.inkMuted),
                      onTap: () => widget.onAbrir(
                        ColaboradorDetalheScreen(colaboradorId: c.id!),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
