import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/app_services.dart';
import 'theme/hc_theme.dart';

class EntregasEpiApp extends StatelessWidget {
  const EntregasEpiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessao = AppServices.of(context).sessao;
    return MaterialApp(
      title: 'EPI · HC Assessoria',
      debugShowCheckedModeBanner: false,
      theme: buildHcTheme(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Troca entre login e área logada conforme a sessão muda.
      home: ListenableBuilder(
        listenable: sessao,
        builder: (context, _) =>
            sessao.logado ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}
