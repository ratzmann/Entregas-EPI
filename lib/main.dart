import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/repositorios.dart';
import 'services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = await AppDatabase.abrir();
  final prefs = await SharedPreferences.getInstance();
  final sessao = Sessao(UsuarioRepositorio(db), prefs);
  await sessao.restaurar();

  runApp(AppServices(db: db, sessao: sessao, child: const EntregasEpiApp()));
}
