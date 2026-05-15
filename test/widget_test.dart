// Basic smoke test for Namma Metro Sahaya app
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:namm_metro_sahaya/main.dart';
import 'package:namm_metro_sahaya/viewmodels/settings_viewmodel.dart';
import 'package:namm_metro_sahaya/viewmodels/route_viewmodel.dart';
import 'package:namm_metro_sahaya/viewmodels/exit_viewmodel.dart';
import 'package:namm_metro_sahaya/viewmodels/admin_viewmodel.dart';
import 'package:namm_metro_sahaya/data/repositories/route_repository.dart';
import 'package:namm_metro_sahaya/data/repositories/exit_repository.dart';

void main() {
  testWidgets('Home screen renders Plan My Journey button',
      (WidgetTester tester) async {
    final routeRepo = RouteRepository();
    final exitRepo = ExitRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsViewModel()),
          ChangeNotifierProvider(create: (_) => RouteViewModel(routeRepo)),
          ChangeNotifierProvider(create: (_) => ExitViewModel(exitRepo)),
          ChangeNotifierProvider(create: (_) => AdminViewModel(exitRepo)),
        ],
        child: const NammaMetroApp(),
      ),
    );

    // Verify the Plan My Journey button is present
    expect(find.text('Plan My Journey'), findsOneWidget);
    expect(find.text('Namma Metro Sahaya'), findsOneWidget);
  });
}
