import 'dart:io' show Platform;

// Native platform check — used on Android, iOS, desktop.
bool get isAndroidPlatform => Platform.isAndroid;
