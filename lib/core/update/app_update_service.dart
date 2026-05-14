import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'app_update_info.dart';

class AppUpdateService {
  AppUpdateService({
    required this.manifestUri,
    HttpClient Function()? httpClientFactory,
  }) : _httpClientFactory = httpClientFactory ?? HttpClient.new;

  static const defaultManifestUrl =
      'https://raw.githubusercontent.com/shxzzxz/smartflow/main/release/update-beta.json';

  final Uri manifestUri;
  final HttpClient Function() _httpClientFactory;

  Future<AppUpdateInfo> fetchUpdateInfo() async {
    final client = _httpClientFactory();
    try {
      final request = await client.getUrl(manifestUri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'SmartFlow');
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Update manifest request failed: ${response.statusCode}.',
          uri: manifestUri,
        );
      }

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body);
      if (json is! Map<String, Object?>) {
        throw const FormatException('Update manifest must be a JSON object.');
      }

      return AppUpdateInfo.fromJson(json);
    } finally {
      client.close(force: true);
    }
  }

  Future<AppUpdateInfo?> checkForUpdate({
    required int currentBuildNumber,
  }) async {
    final info = await fetchUpdateInfo();
    return info.isNewerThan(currentBuildNumber) ? info : null;
  }

  Future<File> downloadApk(
    AppUpdateInfo info, {
    void Function(AppUpdateDownloadProgress progress)? onProgress,
  }) async {
    final uri = Uri.parse(info.apkUrl);
    final directory = await getTemporaryDirectory();
    final file = File(
      path.join(
        directory.path,
        'smartflow-${info.versionName}-${info.versionCode}.apk',
      ),
    );

    final client = _httpClientFactory();
    IOSink? sink;
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, 'SmartFlow');
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'APK request failed: ${response.statusCode}.',
          uri: uri,
        );
      }

      final totalBytes =
          response.contentLength >= 0 ? response.contentLength : null;
      var receivedBytes = 0;
      sink = file.openWrite();

      await for (final chunk in response) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        onProgress?.call(
          AppUpdateDownloadProgress(
            receivedBytes: receivedBytes,
            totalBytes: totalBytes,
          ),
        );
      }

      await sink.close();
      sink = null;
      return file;
    } finally {
      await sink?.close();
      client.close(force: true);
    }
  }
}
