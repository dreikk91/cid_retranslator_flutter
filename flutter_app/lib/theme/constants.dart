import 'package:flutter/material.dart';

class AppColors {
  // Windows 11 Background colors
  static const win11Background = Color(0xFFF3F3F3);
  static const win11CardBackground = Color(0xFFFFFFFF);
  static const win11Border = Color(0xFFE5E5E5);

  // Text colors
  static const win11TextPrimary = Color(0xFF1F1F1F);
  static const win11TextSecondary = Color(0xFF606060);

  // Accent colors
  static const win11Accent = Color(0xFF0078D4);
  static const win11AccentLight = Color(0xFFCCE4F7);

  // Status colors
  static const win11Success = Color(0xFF107C10);
  static const win11Error = Color(0xFFC42B1C);
  static const win11Warning = Color(0xFFFFB900);

  // Event priority colors
  static const unknownEventBg = Color(0xFFF3F3F3);
  static const unknownEventText = Color(0xFF606060);

  static const guardEventBg = Color(0xFFE8F4FF);
  static const guardEventText = Color(0xFF0063B1);

  static const disguardEventBg = Color(0xFFDFF6DD);
  static const disguardEventText = Color(0xFF107C10);

  static const okEventBg = Color(0xFFFFFBE6);
  static const okEventText = Color(0xFF946500);

  static const alarmEventBg = Color(0xFFFDE7E9);
  static const alarmEventText = Color(0xFFC42B1C);

  static const otherEventBg = Color(0xFFFAFAFA);
  static const otherEventText = Color(0xFF1F1F1F);

  // PPK colors
  static const ppkTimeoutBg = Color(0xFFC42B1C);
  static const ppkTimeoutText = Color(0xFFFFFFFF);
  static const ppkGray = Color(0xFFFAFAFA);
  static const ppkBlack = Color(0xFF1F1F1F);

  static const colorGreen = Color(0xFF107C10);
  static const colorRed = Color(0xFFC42B1C);
  static const colorOrange = Color(0xFFFFB900);

  // Status bar colors
  static const statusBarBg = Color(0xFFF9F9F9);
  static const statusBarText = Color(0xFF1F1F1F);
  static const statusBarSeparator = Color(0xFFEDEDED);

  static const statusConnectedBg = Color(0xFF107C10);
  static const statusDisconnectedBg = Color(0xFFC42B1C);

  static const counterAcceptedIcon = Color(0xFF107C10);
  static const counterRejectedIcon = Color(0xFFC42B1C);
  static const counterReconnectIcon = Color(0xFFCA5010);
  static const counterUptimeIcon = Color(0xFF0078D4);
}

// Event priority constants
class EventPriority {
  static const int unknown = 0;
  static const int guard = 1;
  static const int disguard = 2;
  static const int ok = 3;
  static const int alarm = 4;
  static const int other = 5;
}
