import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vima/main.dart';
import 'package:vima/core/di/injection_container.dart';
import 'package:vima/presentation/widgets/animated_rainbow.dart';

void main() {
  testWidgets('MoneyApp renders correctly', (WidgetTester tester) async {
    // Initialize mock values for SharedPreferences before starting DI
    SharedPreferences.setMockInitialValues({});
    await initDependencies();

    await tester.pumpWidget(
      const RainbowAnimationGroup(
        child: MoneyApp(isLoggedIn: false),
      ),
    );

    // Verify VIMA branding is visible on the login screen
    expect(find.text('VIMA'), findsOneWidget);
  });
}
