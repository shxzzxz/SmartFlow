import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/core/update/app_update_info.dart';

void main() {
  group('AppUpdateInfo', () {
    test('parses update manifest', () {
      final info = AppUpdateInfo.fromJson({
        'channel': 'beta',
        'versionName': '0.1.1',
        'versionCode': 11,
        'apkUrl':
            'https://github.com/shxzzxz/smartflow/releases/download/v0.1.1/smartflow-0.1.1+11.apk',
        'releaseUrl':
            'https://github.com/shxzzxz/smartflow/releases/tag/v0.1.1',
        'required': false,
        'notes': 'SmartFlow 0.1.1 内测版本。',
      });

      expect(info.channel, 'beta');
      expect(info.versionName, '0.1.1');
      expect(info.versionCode, 11);
      expect(info.required, isFalse);
      expect(info.notes, 'SmartFlow 0.1.1 内测版本。');
    });

    test('compares updates by versionCode', () {
      final info = AppUpdateInfo.fromJson({
        'channel': 'beta',
        'versionName': '0.1.1',
        'versionCode': '11',
        'apkUrl': 'https://example.com/smartflow.apk',
        'releaseUrl': '',
      });

      expect(info.isNewerThan(10), isTrue);
      expect(info.isNewerThan(11), isFalse);
      expect(info.isNewerThan(12), isFalse);
    });

    test('rejects incomplete manifest', () {
      expect(
        () => AppUpdateInfo.fromJson({
          'channel': 'beta',
          'versionName': '0.1.1',
          'versionCode': 11,
        }),
        throwsFormatException,
      );
    });
  });
}
