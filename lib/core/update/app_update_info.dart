class AppUpdateInfo {
  const AppUpdateInfo({
    required this.channel,
    required this.versionName,
    required this.versionCode,
    required this.apkUrl,
    required this.releaseUrl,
    required this.required,
    required this.notes,
  });

  final String channel;
  final String versionName;
  final int versionCode;
  final String apkUrl;
  final String releaseUrl;
  final bool required;
  final String notes;

  factory AppUpdateInfo.fromJson(Map<String, Object?> json) {
    final channel = _readString(json, 'channel');
    final versionName = _readString(json, 'versionName');
    final versionCode = _readInt(json, 'versionCode');
    final apkUrl = _readString(json, 'apkUrl');
    final releaseUrl = _readString(json, 'releaseUrl');
    final notes = _readOptionalString(json, 'notes');
    final required = json['required'] == true;

    if (channel.isEmpty ||
        versionName.isEmpty ||
        versionCode <= 0 ||
        apkUrl.isEmpty) {
      throw const FormatException('Invalid update manifest.');
    }

    return AppUpdateInfo(
      channel: channel,
      versionName: versionName,
      versionCode: versionCode,
      apkUrl: apkUrl,
      releaseUrl: releaseUrl,
      required: required,
      notes: notes,
    );
  }

  bool isNewerThan(int currentBuildNumber) {
    return versionCode > currentBuildNumber;
  }

  static String _readString(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is String ? value.trim() : '';
  }

  static String _readOptionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is String ? value.trim() : '';
  }

  static int _readInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class AppVersionInfo {
  const AppVersionInfo({required this.versionName, required this.buildNumber});

  final String versionName;
  final int buildNumber;

  String get displayName => '$versionName+$buildNumber';
}

class AppUpdateDownloadProgress {
  const AppUpdateDownloadProgress({
    required this.receivedBytes,
    required this.totalBytes,
  });

  final int receivedBytes;
  final int? totalBytes;

  double? get fraction {
    final total = totalBytes;
    if (total == null || total <= 0) {
      return null;
    }
    return receivedBytes / total;
  }
}
