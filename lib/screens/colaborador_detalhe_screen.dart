import 'package:material_ui/material_ui.dart';

import '../data/models.dart';
import '../services/app_services.dart';
import '../theme/hc_theme.dart';
import '../widgets/comuns.dart';
import '../widgets/entrega_tile.dart';
import 'colaborador_form_screen.dart';
import 'entrega_detalhe_screen.dart';
import 'entrega_form_screen.dart';

/// Ficha de EPI do colaborador: dados e histórico de entregas.
class ColaboradorDetalheScreen extends StatefulWidget {
  final int colaboradorId;
  const ColaboradorDetalheScreen({super.key, required this.colaboradorId});

  @override
  State<ColaboradorDetalheScreen> createState() =>
      _ColaboradorDetalheScreenState();
}

class _ColaboradorDetalheScreenState extends State<ColaboradorDetalheScreen> {
  Future<(Colaborador?, List<Entrega>)>? _dados;
  // Avisa a tela anterior para recarregar se algo mudou aqui.
  bool _alterou = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dados ??= _carregar();
  }

  Future<(Colaborador?, List<Entrega>)> _carregar() async {
    final s = AppServices.of(context);
    return (
      await s.colaboradores.porId(widget.colaboradorId),
      await s.entregas.listar(colaboradorId: widget.colaboradorId),
    );
  }

  Future<void> _abrir(Widget tela) async {
    final r = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => tela));
    if (r == true) {
      setState(() {
        _alterou = true;
        _dados = _carregar();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_alterou);
      },
      child: FutureBuilder<(Colaborador?, List<Entrega>)>(
        future: _dados,
        builder: (context, snap) {
          final c = snap.data?.$1;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ficha do colaborador'),
              actions: [
                if (c != null)
                  IconButton(
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () =>
                        _abrir(ColaboradorFormScreen(colaborador: c)),
                  ),
              ],
            ),
            floatingActionButton: c != null && c.ativo
                ? FloatingActionButton.extended(
                    onPressed: () =>
                        _abrir(EntregaFormScreen(colaboradorId: c.id)),
                    icon: const Icon(Icons.add_task),
                    label: const Text('ENTREGAR EPI'),
                  )
                : null,
            body: _corpo(snap),
          );
        },
      ),
    );
  }

  Widget _corpo(AsyncSnapshot<(Colaborador?, List<Entrega>)> snap) {
    if (!snap.hasData) return const Center(child: CircularProgressIndicator());
    final (c, entregas) = snap.data!;
    if (c == null) {
      return const EstadoVazio(
        icone: Icons.person_off_outlined,
        titulo: 'Colaborador não encontrado',
      );
    }
    final texto = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AvatarIniciais(c.iniciais, ativo: c.ativo),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.nome, style: texto.titleLarge),
                      const SizedBox(height: 2),
                      Text('${c.funcao} · ${c.setor}', style: texto.bodySmall),
                      Text(
                        'Matrícula ${c.matricula} · CPF ${c.cpf}',
                        style: texto.bodySmall,
                      ),
                      if (!c.ativo) ...[
                        const SizedBox(height: 6),
                        const Etiqueta('Inativo', cor: HcColors.inkMuted),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Eyebrow('Histórico de entregas · ${entregas.length}'),
        const SizedBox(height: 8),
        if (entregas.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nenhum EPI entregue a este colaborador ainda.'),
            ),
          )
        else
          for (final e in entregas)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EntregaTile(
                entrega: e,
                mostrarColaborador: false,
                onTap: () => _abrir(EntregaDetalheScreen(entregaId: e.id)),
              ),
            ),
      ],
    );
  }
}
