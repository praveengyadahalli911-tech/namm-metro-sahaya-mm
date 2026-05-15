import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namm_metro_sahaya/main.dart';
import 'package:namm_metro_sahaya/ui/screens/route_query_screen.dart';
import 'package:namm_metro_sahaya/ui/screens/route_result_screen.dart';

import 'package:namm_metro_sahaya/viewmodels/settings_viewmodel.dart';
import 'package:namm_metro_sahaya/viewmodels/route_viewmodel.dart';
import 'package:namm_metro_sahaya/viewmodels/exit_viewmodel.dart';
import 'package:namm_metro_sahaya/viewmodels/admin_viewmodel.dart';
import 'package:namm_metro_sahaya/viewmodels/nl_query_viewmodel.dart';
import 'package:namm_metro_sahaya/data/repositories/route_repository.dart';
import 'package:namm_metro_sahaya/data/repositories/exit_repository.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('End-to-End App Flow Test', (WidgetTester tester) async {
    final routeRepository = RouteRepository();
    final exitRepository = ExitRepository();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsViewModel()),
          ChangeNotifierProvider(create: (_) => RouteViewModel(routeRepository)),
          ChangeNotifierProvider(create: (_) => ExitViewModel(exitRepository)),
          ChangeNotifierProvider(create: (_) => AdminViewModel(exitRepository)),
          ChangeNotifierProvider(create: (_) => NLQueryViewModel()),
        ],
        child: const NammaMetroApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify we are on the intro screen and tap 'Plan My Journey'
    expect(find.text('Plan My Journey'), findsOneWidget);
    await tester.tap(find.text('Plan My Journey'));
    await tester.pumpAndSettle();

    // Verify we are on the RouteQueryScreen
    expect(find.byType(RouteQueryScreen), findsOneWidget);

    // Find the Autocomplete TextFields
    // The first one is the source, second is the destination
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    // Instead of fighting the Autocomplete overlay in headless widget tests,
    // we'll simulate the user selection by setting the ViewModel directly.
    final context = tester.element(find.byType(RouteQueryScreen));
    final routeVM = Provider.of<RouteViewModel>(context, listen: false);
    
    // Stations from dummy data
    final majestic = routeVM.allStations.first;
    final banashankari = routeVM.allStations.last;
    
    routeVM.setSource(majestic);
    routeVM.setDestination(banashankari);
    
    await tester.pumpAndSettle();

    // Tap Find Route button
    final findRouteBtn = find.text('Find Route');
    expect(findRouteBtn, findsOneWidget);
    await tester.tap(findRouteBtn);
    await tester.pumpAndSettle();

    // Wait for route computation to finish
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // We should now be on the RouteResultScreen
    expect(find.byType(RouteResultScreen), findsOneWidget);

    // Verify that the route stats are visible
    expect(find.text('Fare'), findsOneWidget);
    expect(find.text('Est. Time'), findsOneWidget);
    expect(find.text('Stops'), findsOneWidget);

    // Verify that the "Show Me How", "Which Gate?", and "Last Mile" buttons are present
    expect(find.text('Show Me How'), findsOneWidget);
    expect(find.text('Gate?'), findsOneWidget);
    expect(find.text('Last Mile'), findsOneWidget);

    // Tap the "Last Mile" button
    await tester.tap(find.text('Last Mile'));
    await tester.pumpAndSettle();

    // Verify we navigated to the LastMileScreen and see BMTC Feeder Buses
    expect(find.text('BMTC Feeder Buses'), findsOneWidget);
    expect(find.text('Auto Rickshaw Stands'), findsOneWidget);
    
    // Go back to result screen
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tap the Emergency Quick Action button on the home screen? We'd have to go back.
    // Let's just verify the quick actions exist on RouteQueryScreen
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Emergency'), findsOneWidget);
  });
}
