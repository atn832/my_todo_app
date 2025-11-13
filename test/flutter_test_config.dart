import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// https://api.flutter.dev/flutter/flutter_test/GoldenFileComparator-class.html#including-fonts
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() async {
    final Future<ByteData> font = rootBundle.load(
      'assets/Roboto-VariableFont_wdth,wght.ttf',
    );
    final FontLoader fontLoader = FontLoader('Roboto')..addFont(font);
    await fontLoader.load();
  });

  await testMain();
}
