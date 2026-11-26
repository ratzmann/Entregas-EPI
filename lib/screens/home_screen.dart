import 'package:material_ui/material_ui.dart';

import '../services/app_services.dart';
import '../theme/hc_theme.dart';
import 'colaborador_form_screen.dart';
import 'colaboradores_screen.dart';
import 'entrega_form_screen.dart';
import 'entregas_screen.dart';
import 'epi_form_screen.dart';
import 'epis_screen.dart';
import 'painel_screen.dart';

/// Área logada: navegação inferior entre painel, entregas, colaboradores e EPIs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _aba = 0;
  // Incrementado para recarregar a aba atual depois de um cadastro.
  int _versao = 0;

  static const _titulos = ['Painel', 'Entregas', 'Colaboradores', 'EPIs'];

  Future<void> _abrir(Widget tela) async {
    final alterou = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => tela));
    if (alterou == true) setState(() => _versao++);
  }

  void _irPara(int aba) => setState(() => _aba = aba);

  Widget _corpo() {
    switch (_aba) {
      case 0:
        return PainelScreen(onAbrir: _abrir, onIrPara: _irPara);
      case 1:
        return EntregasScreen(onAbrir: _abrir);
      case 2:
        return ColaboradoresScreen(onAbrir: _abrir);
      default:
        return EpisScreen(onAbrir: _abrir);
    }
  }

  Widget? _fab() {
    switch (_aba) {
      case 0:
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => _abrir(const EntregaFormScreen()),
          icon: const Icon(Icons.add_task),
          label: const Text('NOVA ENTREGA'),
        );
      case 2:
        return FloatingActionButton(
          tooltip: 'Novo colaborador',
          onPressed: () => _abrir(const ColaboradorFormScreen()),
          child: const Icon(Icons.person_add_alt_1),
        );
      default:
        return FloatingActionButton(
          tooltip: 'Novo EPI',
          onPressed: () => _abrir(const EpiFormScreen()),
          child: const Icon(Icons.add),
        );
    }
  }

  Future<void> _confirmarSaida() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
          'Você precisará entrar novamente para registrar entregas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (sair == true && mounted) await AppServices.of(context).sessao.sair();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AppServices.of(context).sessao.usuario;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_aba]),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Conta',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: HcColors.brand,
              child: Text(
                (usuario?.nome.isNotEmpty ?? false)
                    ? usuario!.nome[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: HcColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            onSelected: (_) => _confirmarSaida(),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(
                  '${usuario?.nome}\n${usuario?.email}',
                  style: const TextStyle(
                    color: HcColors.inkMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'sair',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: KeyedSubtree(key: ValueKey('$_aba-$_versao'), child: _corpo()),
      floatingActionButton: _fab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: _irPara,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Painel',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Entregas',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Colaboradores',
          ),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_outlined),
            selectedIcon: Icon(Icons.health_and_safety),
            label: 'EPIs',
          ),
        ],
      ),
    );
  }
}

/// Assinatura comum das abas para abrir telas que podem alterar dados.
typedef AbrirTela = Future<void> Function(Widget tela);
