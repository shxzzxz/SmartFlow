import 'package:flutter/services.dart';

import 'app_update_info.dart';

class AppUpdatePlatform {
  const AppUpdatePlatform();

  static const MethodChannel _channel = MethodChannel(
    'com.shxzz.smartflow/app_update',
  );

  Future<AppVersionInfo> getVersionInfo() async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'getVersionInfo',
    );
    if (result == null) {
      throw StateError('Missing app version info.');
    }

    final versionName = result['versionName'];
    final buildNumber = result['buildNumber'];

    return AppVersionInfo(
      versionName: versionName is String ? versionName : '',
      buildNumber:
          buildNumber is int
              ? buildNumber
              : int.tryParse(buildNumber.toString()) ?? 0,
    );
  }

  Future<void> installApk(String filePath) async {
    await _channel.invokeMethod<void>('installApk', {'filePath': filePath});
  }
}
