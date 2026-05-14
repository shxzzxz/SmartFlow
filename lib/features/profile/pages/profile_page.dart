import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

import '../../../core/update/app_update_channel.dart';
import '../../../core/update/app_update_info.dart';
import '../../../core/update/app_update_platform.dart';
import '../../../core/update/app_update_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../design_system/theme/app_text_styles.dart';
import '../../../design_system/tokens/radius.dart';
import '../../../design_system/tokens/spacing.dart';
import '../../../design_system/widgets/app_surface.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  static const _updateChannelKey = 'update.channel';
  static const _manifestUrlOverride = String.fromEnvironment(
    'SMARTFLOW_UPDATE_URL',
    defaultValue: '',
  );
  static const _manifestBaseUrl = String.fromEnvironment(
    'SMARTFLOW_UPDATE_BASE_URL',
    defaultValue: AppUpdateService.defaultManifestBaseUrl,
  );
  static final _defaultUpdateChannel = AppUpdateChannel.fromCode(
    const String.fromEnvironment(
      'SMARTFLOW_UPDATE_CHANNEL',
      defaultValue: 'beta',
    ),
  );

  final _updatePlatform = const AppUpdatePlatform();

  AppVersionInfo? _versionInfo;
  AppUpdateChannel _updateChannel = _defaultUpdateChannel;
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
    _loadUpdateChannel();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final versionInfo = await _updatePlatform.getVersionInfo();
      if (!mounted) {
        return;
      }
      setState(() => _versionInfo = versionInfo);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _versionInfo = const AppVersionInfo(
              versionName: '未知版本',
              buildNumber: 0,
            ),
      );
    }
  }

  Future<void> _loadUpdateChannel() async {
    try {
      final database = ref.read(appDatabaseProvider);
      final row =
          await (database.select(database.appMetadata)..where(
            (table) => table.key.equals(_updateChannelKey),
          )).getSingleOrNull();
      if (!mounted || row == null) {
        return;
      }
      setState(() => _updateChannel = AppUpdateChannel.fromCode(row.value));
    } catch (_) {
      // Keep the compile-time default channel when local metadata is unreadable.
    }
  }

  Future<void> _setUpdateChannel(AppUpdateChannel channel) async {
    if (channel == _updateChannel) {
      return;
    }

    setState(() => _updateChannel = channel);
    final database = ref.read(appDatabaseProvider);
    await database
        .into(database.appMetadata)
        .insertOnConflictUpdate(
          AppMetadataCompanion.insert(
            key: _updateChannelKey,
            value: channel.code,
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> _checkForUpdate() async {
    if (_isCheckingUpdate) {
      return;
    }

    var versionInfo = _versionInfo;
    if (versionInfo == null || versionInfo.buildNumber <= 0) {
      await _loadVersionInfo();
      versionInfo = _versionInfo;
    }

    if (!mounted) {
      return;
    }

    if (versionInfo == null || versionInfo.buildNumber <= 0) {
      _showMessage('暂时无法读取当前版本');
      return;
    }

    setState(() => _isCheckingUpdate = true);
    try {
      final updateService = _createUpdateService();
      final updateInfo = await updateService.checkForUpdate(
        currentBuildNumber: versionInfo.buildNumber,
      );
      if (!mounted) {
        return;
      }

      if (updateInfo == null) {
        _showMessage('当前已是最新版本');
        return;
      }

      final supportedAbis = await _updatePlatform.getSupportedAbis();
      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: !updateInfo.required,
        builder:
            (context) => _AppUpdateDialog(
              updateInfo: updateInfo,
              supportedAbis: supportedAbis,
              updateService: updateService,
              updatePlatform: _updatePlatform,
            ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('检查更新失败，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _isCheckingUpdate = false);
      }
    }
  }

  AppUpdateService _createUpdateService() {
    final override = _manifestUrlOverride.trim();
    if (override.isNotEmpty) {
      return AppUpdateService(
        manifestUri: Uri.parse(override),
        expectedChannel: _updateChannel,
      );
    }

    return AppUpdateService(
      manifestUri: AppUpdateService.manifestUriForChannel(
        _updateChannel,
        baseUrl: _manifestBaseUrl,
      ),
      expectedChannel: _updateChannel,
    );
  }

  Future<void> _chooseUpdateChannel() async {
    final selected = await showModalBottomSheet<AppUpdateChannel>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => _UpdateChannelSheet(selectedChannel: _updateChannel),
    );
    if (selected == null || !mounted) {
      return;
    }
    await _setUpdateChannel(selected);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final versionInfo = _versionInfo;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space20,
            AppSpacing.space24,
            AppSpacing.space20,
            AppSpacing.space24,
          ),
          children: [
            Text('我的', style: context.appTextStyles.pageTitle),
            const SizedBox(height: AppSpacing.space20),
            AppSurface(
              child: Column(
                children: [
                  _ProfileActionRow(
                    icon: RemixIcons.apps_2_line,
                    label: '分类管理',
                    description: '维护收入与支出分类',
                    onTap: () => context.push('/categories'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                    ),
                    child: Divider(height: 1),
                  ),
                  _ProfileActionRow(
                    icon: RemixIcons.wallet_3_line,
                    label: '账户管理',
                    description: '管理资产与负债账户',
                    onTap: () => context.go('/accounts'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                    ),
                    child: Divider(height: 1),
                  ),
                  _ProfileActionRow(
                    icon: RemixIcons.download_cloud_2_line,
                    label: _isCheckingUpdate ? '正在检查更新' : '检查更新',
                    description:
                        versionInfo == null
                            ? '正在读取当前版本'
                            : '当前版本 ${versionInfo.displayName}',
                    onTap: _checkForUpdate,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space16,
                    ),
                    child: Divider(height: 1),
                  ),
                  _ProfileActionRow(
                    icon: RemixIcons.git_branch_line,
                    label: '更新渠道',
                    description:
                        '${_updateChannel.label} · ${_updateChannel.description}',
                    onTap: _chooseUpdateChannel,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppUpdateDialog extends StatefulWidget {
  const _AppUpdateDialog({
    required this.updateInfo,
    required this.supportedAbis,
    required this.updateService,
    required this.updatePlatform,
  });

  final AppUpdateInfo updateInfo;
  final List<String> supportedAbis;
  final AppUpdateService updateService;
  final AppUpdatePlatform updatePlatform;

  @override
  State<_AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<_AppUpdateDialog> {
  bool _isDownloading = false;
  double? _progress;

  Future<void> _downloadAndInstall() async {
    if (_isDownloading) {
      return;
    }

    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final apk = await widget.updateService.downloadApk(
        widget.updateInfo,
        supportedAbis: widget.supportedAbis,
        onProgress: (progress) {
          if (!mounted) {
            return;
          }
          setState(() => _progress = progress.fraction);
        },
      );
      await widget.updatePlatform.installApk(apk.path);
      if (mounted && !widget.updateInfo.required) {
        Navigator.of(context).pop();
      }
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      final message =
          error.code == 'installPermissionRequired'
              ? '请允许 SmartFlow 安装未知应用后重试'
              : '安装失败，请稍后重试';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('下载失败，请稍后重试')));
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = context.appTextStyles;
    final progress = _progress;
    final package = widget.updateInfo.resolvePackage(widget.supportedAbis);

    return AlertDialog(
      title: Text('发现新版本 ${widget.updateInfo.versionName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.updateInfo.notes.isNotEmpty)
            Text(widget.updateInfo.notes, style: textStyles.detailValue),
          if (widget.updateInfo.notes.isEmpty)
            Text('有新的内测版本可用。', style: textStyles.detailValue),
          const SizedBox(height: AppSpacing.space12),
          Text(
            package.abi == 'universal' ? '安装包：通用包' : '安装包：${package.abi}',
            style: textStyles.listSupporting.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (_isDownloading) ...[
            const SizedBox(height: AppSpacing.space16),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: AppSpacing.space8),
            Text(
              progress == null ? '正在下载' : '已下载 ${(progress * 100).round()}%',
              style: textStyles.listSupporting.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!widget.updateInfo.required)
          TextButton(
            onPressed:
                _isDownloading ? null : () => Navigator.of(context).pop(),
            child: const Text('稍后'),
          ),
        FilledButton(
          onPressed: _isDownloading ? null : _downloadAndInstall,
          child: Text(_isDownloading ? '下载中' : '立即更新'),
        ),
      ],
    );
  }
}

class _UpdateChannelSheet extends StatelessWidget {
  const _UpdateChannelSheet({required this.selectedChannel});

  final AppUpdateChannel selectedChannel;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.appTextStyles;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space16,
          0,
          AppSpacing.space16,
          AppSpacing.space16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.space4,
                0,
                AppSpacing.space4,
                AppSpacing.space8,
              ),
              child: Text('更新渠道', style: textStyles.sectionTitle),
            ),
            for (final channel in AppUpdateChannel.values)
              ListTile(
                onTap: () => Navigator.of(context).pop(channel),
                title: Text(channel.label),
                subtitle: Text(channel.description),
                trailing:
                    channel == selectedChannel
                        ? const Icon(RemixIcons.check_line)
                        : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space16,
          vertical: AppSpacing.space14,
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.space48 - AppSpacing.space8,
              height: AppSpacing.space48 - AppSpacing.space8,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.appTextStyles.formValue),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    description,
                    style: context.appTextStyles.listSupporting.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(RemixIcons.arrow_right_s_line, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
