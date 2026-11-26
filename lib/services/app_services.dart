import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../data/models.dart';
import '../data/repositorios.dart';

/// Guarda o usuário logado e mantém a sessão entre aberturas do app.
class Sessao extends ChangeNotifier {
  static const _chave = 'usuario_logado_id';

  final UsuarioRepositorio _usuarios;
  final SharedPreferences _prefs;
  Usuario? _usuario;

  Sessao(this._usuarios, this._prefs);

  Usuario? get usuario => _usuario;
  bool get logado => _usuario != null;

  Future<void> restaurar() async {
    final id = _prefs.getInt(_chave);
    if (id != null) _usuario = await _usuarios.porId(id);
  }

  Future<bool> entrar(String email, String senha) async {
    final u = await _usuarios.autenticar(email, senha);
    if (u == null) return false;
    await _definir(u);
    return true;
  }

  Future<void> cadastrarEEntrar(String nome, String email, String senha) async {
    await _definir(await _usuarios.cadastrar(nome, email, senha));
  }

  Future<void> sair() async {
    _usuario = null;
    await _prefs.remove(_chave);
    notifyListeners();
  }

  Future<void> _definir(Usuario u) async {
    _usuario = u;
    await _prefs.setInt(_chave, u.id!);
    notifyListeners();
  }
}

/// Container simples de dependências, acessível por `AppServices.of(context)`.
class AppServices extends InheritedWidget {
  final Sessao sessao;
  final ColaboradorRepositorio colaboradores;
  final EpiRepositorio epis;
  final EntregaRepositorio entregas;

  AppServices({
    super.key,
    required Database db,
    required this.sessao,
    required super.child,
  }) : colaboradores = ColaboradorRepositorio(db),
       epis = EpiRepositorio(db),
       entregas = EntregaRepositorio(db);

  static AppServices of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppServices>()!;

  @override
  bool updateShouldNotify(AppServices oldWidget) => false;
}
