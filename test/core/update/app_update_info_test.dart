import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/core/update/app_update_channel.dart';
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
        'apkSha256': 'ABCDEF',
        'apkSize': '456',
        'releaseUrl':
            'https://github.com/shxzzxz/smartflow/releases/tag/v0.1.1',
        'required': false,
        'notes': 'SmartFlow 0.1.1 内测版本。',
      });

      expect(info.channel, AppUpdateChannel.beta);
      expect(info.versionName, '0.1.1');
      expect(info.versionCode, 11);
      expect(info.apkSha256, 'abcdef');
      expect(info.apkSize, 456);
      expect(info.required, isFalse);
      expect(info.notes, 'SmartFlow 0.1.1 内测版本。');
    });

    test('parses split APK packages', () {
      final info = AppUpdateInfo.fromJson({
        'channel': 'beta',
        'versionName': '0.1.3-beta.1',
        'versionCode': 13,
        'apkUrl': 'https://example.com/smartflow.apk',
        'apkSha256': '123456',
        'apkSize': 456,
        'releaseUrl': '',
        'apks': [
          {
            'abi': 'arm64-v8a',
            'url': 'https://example.com/smartflow-arm64.apk',
            'sha256': 'ABCDEF',
            'size': 123,
          },
          {
            'abi': 'armeabi-v7a',
            'url': 'https://example.com/smartflow-arm.apk',
          },
        ],
      });

      expect(info.packages, hasLength(2));
      expect(info.packages.first.abi, 'arm64-v8a');
      expect(info.packages.first.sha256, 'abcdef');
      expect(info.packages.first.size, 123);
    });

    test('resolves package by supported ABI with universal fallback', () {
      final info = AppUpdateInfo.fromJson({
        'channel': 'beta',
        'versionName': '0.1.3-beta.1',
        'versionCode': 13,
        'apkUrl': 'https://example.com/smartflow.apk',
        'apkSha256': '123456',
        'apkSize': 456,
        'releaseUrl': '',
        'apks': [
          {
            'abi': 'arm64-v8a',
            'url': 'https://example.com/smartflow-arm64.apk',
          },
        ],
      });

      expect(
        info.resolvePackage(['x86_64', 'arm64-v8a']).url,
        'https://example.com/smartflow-arm64.apk',
      );
      final fallback = info.resolvePackage(['armeabi-v7a']);
      expect(fallback.abi, 'universal');
      expect(fallback.url, 'https://example.com/smartflow.apk');
      expect(fallback.sha256, '123456');
      expect(fallback.size, 456);
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
