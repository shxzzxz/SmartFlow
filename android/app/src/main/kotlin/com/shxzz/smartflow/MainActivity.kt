package com.shxzz.smartflow

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val updateChannel = "com.shxzz.smartflow/app_update"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, updateChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getVersionInfo" -> result.success(getVersionInfo())
                    "installApk" -> {
                        val filePath = call.argument<String>("filePath")
                        if (filePath.isNullOrBlank()) {
                            result.error("invalidPath", "APK file path is required.", null)
                            return@setMethodCallHandler
                        }
                        installApk(filePath, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getVersionInfo(): Map<String, Any> {
        val packageInfo =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(0),
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, 0)
            }

        val buildNumber =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode
            } else {
                @Suppress("DEPRECATION")
                packageInfo.versionCode.toLong()
            }

        return mapOf(
            "versionName" to (packageInfo.versionName ?: ""),
            "buildNumber" to buildNumber,
        )
    }

    private fun installApk(filePath: String, result: MethodChannel.Result) {
        val apkFile = File(filePath)
        if (!apkFile.exists()) {
            result.error("fileNotFound", "APK file does not exist.", null)
            return
        }

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
                !packageManager.canRequestPackageInstalls()
        ) {
            val intent =
                Intent(
                    Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                    Uri.parse("package:$packageName"),
                ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.error(
                "installPermissionRequired",
                "Install unknown apps permission is required.",
                null,
            )
            return
        }

        val apkUri =
            FileProvider.getUriForFile(
                this,
                "$packageName.fileprovider",
                apkFile,
            )

        val intent =
            Intent(Intent.ACTION_VIEW)
                .setDataAndType(apkUri, "application/vnd.android.package-archive")
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        startActivity(intent)
        result.success(null)
    }
}
