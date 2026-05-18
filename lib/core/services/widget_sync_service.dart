import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class WidgetSyncService {
  static const androidWidgetName = 'LocketHomeWidgetProvider';
  static const iosWidgetName = 'LocketWidget';

  static const sizeKey = 'widgetSize';
  static const themeColorKey = 'widgetThemeColor';
  static const usernameKey = 'widgetUsername';
  static const captionKey = 'widgetCaption';
  static const timestampKey = 'widgetTimestamp';
  static const imagePathKey = 'widgetImagePath';
  static const avatarImagePathKey = 'widgetAvatarImagePath';

  Future<String> getSize({String fallback = 'Small'}) async {
    return await HomeWidget.getWidgetData<String>(
          sizeKey,
          defaultValue: fallback,
        ) ??
        fallback;
  }

  Future<int> getThemeColor({required Color fallback}) async {
    return await HomeWidget.getWidgetData<int>(
          themeColorKey,
          defaultValue: fallback.toARGB32(),
        ) ??
        fallback.toARGB32();
  }

  Future<void> syncSettings({
    required String size,
    required Color themeColor,
  }) async {
    await HomeWidget.saveWidgetData<String>(sizeKey, size);
    await HomeWidget.saveWidgetData<int>(themeColorKey, themeColor.toARGB32());
    await _updateWidget();
  }

  Future<void> syncPreviewData({
    String username = '',
    String caption = 'saturday afternoon',
    String timestamp = '2m',
  }) async {
    await HomeWidget.saveWidgetData<String>(usernameKey, username);
    await HomeWidget.saveWidgetData<String>(captionKey, caption);
    await HomeWidget.saveWidgetData<String>(timestampKey, timestamp);
    await _updateWidget();
  }

  Future<void> syncLatestPost({
    required String imageUrl,
    required String username,
    String avatarUrl = '',
    required String caption,
    required String timestamp,
  }) async {
    await HomeWidget.saveWidgetData<String>(usernameKey, username);
    await HomeWidget.saveWidgetData<String>(
      captionKey,
      caption.trim().isEmpty ? 'No caption' : caption.trim(),
    );
    await HomeWidget.saveWidgetData<String>(timestampKey, timestamp);

    if (imageUrl.trim().isEmpty) {
      await HomeWidget.saveWidgetData<String?>(imagePathKey, null);
    } else {
      await HomeWidget.saveImage(imagePathKey, NetworkImage(imageUrl.trim()));
    }

    if (avatarUrl.trim().isEmpty) {
      await HomeWidget.saveWidgetData<String?>(avatarImagePathKey, null);
    } else {
      await HomeWidget.saveImage(
        avatarImagePathKey,
        NetworkImage(avatarUrl.trim()),
      );
    }

    await _updateWidget();
  }

  Future<bool> isCreateWidgetSupported() async {
    return await HomeWidget.isRequestPinWidgetSupported() ?? false;
  }

  Future<void> createWidget() async {
    await HomeWidget.requestPinWidget(androidName: androidWidgetName);
  }

  Future<void> _updateWidget() {
    return HomeWidget.updateWidget(
      androidName: androidWidgetName,
      iOSName: iosWidgetName,
    );
  }
}
