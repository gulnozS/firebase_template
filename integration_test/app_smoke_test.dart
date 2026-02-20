import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app smoke test scaffold', (tester) async {
    // This is intentionally a scaffold test. Wire your app bootstrap with
    // test Firebase options or Firebase Emulator Suite before enabling.
    expect(1 + 1, 2);
  }, skip: true);
}
