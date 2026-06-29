import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/repositories/app_repository.dart';

enum AppTargetScreen { checking, register, home, showDialog }

class SplashProvider extends ChangeNotifier {
  final AppRepository _repository;
  final int currentVersion = 6;

  AppTargetScreen _targetScreen = AppTargetScreen.checking;
  AppTargetScreen get targetScreen => _targetScreen;

  String _apkUrl = "";
  String get apkUrl => _apkUrl;

  int _downloadProgress = 0;
  int get downloadProgress => _downloadProgress;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  String _downloadedPath = "";
  String get downloadedPath => _downloadedPath;

  SplashProvider(this._repository);

  Future<void> initSplashLogic() async {
    final updateData = await _repository.checkAppUpdate();

    if (updateData != null) {
      final latestVersion = int.tryParse(updateData['versionCode']?.toString() ?? '') ?? currentVersion;
      _apkUrl = updateData['apkUrl']?.toString() ?? '';

      if (latestVersion > currentVersion && _apkUrl.isNotEmpty) {
        _targetScreen = AppTargetScreen.showDialog;
        notifyListeners();
        return;
      }
    }
    await evaluateNavigation();
  }

  Future<void> evaluateNavigation() async {
    final email = await _repository.getUserEmail();
    if (email == null || email.isEmpty) {
      _targetScreen = AppTargetScreen.register;
    } else {
      await _repository.configureUserPresenceAndToken(email);
      _targetScreen = AppTargetScreen.home;
    }
    notifyListeners();
  }

  Future<bool> checkInstallPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.requestInstallPackages.status;
      if (!status.isGranted) {
        status = await Permission.requestInstallPackages.request();
        return status.isGranted;
      }
      return true;
    }
    return false;
  }

  Future<bool> startApkDownload() async {
    _isDownloading = true;
    _downloadProgress = 0;
    notifyListeners();

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) return false;

      _downloadedPath = '${dir.path}/wintrix_update.apk';
      final dio = Dio();

      await dio.download(
        _apkUrl,
        _downloadedPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress = (received / total * 100).toInt();
            notifyListeners();
          }
        },
      );
      _isDownloading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isDownloading = false;
      notifyListeners();
      return false;
    }
  }
}
