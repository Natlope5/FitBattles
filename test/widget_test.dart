import 'package:camera/camera.dart';
import 'package:fitbattles/auth/login_page.dart';
import 'package:fitbattles/settings/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitbattles/main.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('MyApp initializes correctly', (WidgetTester tester) async {
    // Mock objects for testing
    final notificationsHandler = NotificationsHandler();
    final cameras = <CameraDescription>[]; // Assuming an empty list for the test

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MyApp(
          notificationsHandler: notificationsHandler,
          cameras: cameras,
        ),
      ),
    );

    // Verify that the LoginPage is displayed as initial route
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
