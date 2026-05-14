enum AppUpdateChannel {
  stable(code: 'stable', label: '稳定版', description: '只接收正式发布版本'),
  beta(code: 'beta', label: '尝鲜版', description: '接收尝鲜或稳定版本'),
  dev(code: 'dev', label: '开发版', description: '接收开发、尝鲜或稳定版本');

  const AppUpdateChannel({
    required this.code,
    required this.label,
    required this.description,
  });

  final String code;
  final String label;
  final String description;

  static AppUpdateChannel fromCode(String value) {
    final normalized = value.trim().toLowerCase();
    for (final channel in values) {
      if (channel.code == normalized) {
        return channel;
      }
    }
    return AppUpdateChannel.stable;
  }
}
