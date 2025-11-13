import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// This file sets up fonts for all tests in the folder. This way, screenshot
// tests will render actual text instead of boxes.
// https://api.flutter.dev/flutter/flutter_test/GoldenFileComparator-class.html#including-fonts
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() async {
    final Future<ByteData> font = rootBundle.load(
      'assets/Roboto-VariableFont_wdth,wght.ttf',
    );
    final FontLoader fontLoader = FontLoader('Roboto')..addFont(font);
    await fontLoader.load();
  });

  // Necessary for tests that do not use testWidgets eg unit tests like
  // todo_provider_test. Without it, we get a `Binding has not yet been
  // initialized.` error.
  TestWidgetsFlutterBinding.ensureInitialized();
  await testMain();
}
