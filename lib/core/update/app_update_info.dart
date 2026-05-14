import 'app_update_channel.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.channel,
    required this.versionName,
    required this.versionCode,
    required this.apkUrl,
    this.apkSha256,
    this.apkSize,
    required this.releaseUrl,
    required this.required,
    required this.notes,
    required this.packages,
  });

  final AppUpdateChannel channel;
  final String versionName;
  final int versionCode;
  final String apkUrl;
  final String? apkSha256;
  final int? apkSize;
  final String releaseUrl;
  final bool required;
  final String notes;
  final List<AppUpdatePackage> packages;

  factory AppUpdateInfo.fromJson(Map<String, Object?> json) {
    final channel = AppUpdateChannel.fromCode(_readString(json, 'channel'));
    final versionName = _readString(json, 'versionName');
    final versionCode = _readInt(json, 'versionCode');
    final apkUrl = _readString(json, 'apkUrl');
    final apkSha256 = _readOptionalString(json, 'apkSha256');
    final apkSize = _readOptionalInt(json, 'apkSize');
    final releaseUrl = _readString(json, 'releaseUrl');
    final notes = _readOptionalString(json, 'notes');
    final required = json['required'] == true;
    final packages = _readPackages(json['apks']);

    if (versionName.isEmpty || versionCode <= 0 || apkUrl.isEmpty) {
      throw const FormatException('Invalid update manifest.');
    }

    return AppUpdateInfo(
      channel: channel,
      versionName: versionName,
      versionCode: versionCode,
      apkUrl: apkUrl,
      apkSha256: apkSha256.isEmpty ? null : apkSha256.toLowerCase(),
      apkSize: apkSize,
      releaseUrl: releaseUrl,
      required: required,
      notes: notes,
      packages: packages,
    );
  }

  bool isNewerThan(int currentBuildNumber) {
    return versionCode > currentBuildNumber;
  }

  AppUpdatePackage resolvePackage(List<String> supportedAbis) {
    final normalizedAbis = supportedAbis
        .map((abi) => abi.trim())
        .where((abi) => abi.isNotEmpty);
    for (final abi in normalizedAbis) {
      for (final package in packages) {
        if (package.abi == abi) {
          return package;
        }
      }
    }
    return AppUpdatePackage(
      abi: 'universal',
      url: apkUrl,
      sha256: apkSha256,
      size: apkSize,
    );
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

  static int? _readOptionalInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int && value > 0) {
      return value;
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed != null && parsed > 0 ? parsed : null;
    }
    return null;
  }

  static List<AppUpdatePackage> _readPackages(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, Object?>>()
        .map(AppUpdatePackage.fromJson)
        .where((package) => package.abi.isNotEmpty && package.url.isNotEmpty)
        .toList(growable: false);
  }
}

class AppUpdatePackage {
  const AppUpdatePackage({
    required this.abi,
    required this.url,
    this.sha256,
    this.size,
  });

  final String abi;
  final String url;
  final String? sha256;
  final int? size;

  factory AppUpdatePackage.fromJson(Map<String, Object?> json) {
    final abi = _readString(json, 'abi');
    final url = _readString(json, 'url');
    final sha256 = _readOptionalString(json, 'sha256');
    final size = _readOptionalInt(json, 'size');

    return AppUpdatePackage(
      abi: abi,
      url: url,
      sha256: sha256.isEmpty ? null : sha256.toLowerCase(),
      size: size,
    );
  }

  static String _readString(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is String ? value.trim() : '';
  }

  static String _readOptionalString(Map<String, Object?> json, String key) {
    final value = json[key];
    return value is String ? value.trim() : '';
  }

  static int? _readOptionalInt(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is int && value > 0) {
      return value;
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed != null && parsed > 0 ? parsed : null;
    }
    return null;
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
