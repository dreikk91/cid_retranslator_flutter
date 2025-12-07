import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cid_retranslator/theme/app_theme.dart';
import 'package:cid_retranslator/screens/main_screen.dart';
import 'package:cid_retranslator/services/api_service.dart';
import 'package:cid_retranslator/services/websocket_service.dart';
import 'package:cid_retranslator/providers/ppk_provider.dart';
import 'package:cid_retranslator/providers/event_provider.dart';
import 'package:cid_retranslator/providers/stats_provider.dart';
import 'package:cid_retranslator/providers/config_provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    minimumSize: Size(600, 480),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'CID Ретранслятор - Система моніторингу',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create services
    final apiService = ApiService();
    final wsService = WebSocketService();

    // Connect WebSocket
    wsService.connect();

    return MultiProvider(
      providers: [
        // Services
        Provider<ApiService>.value(value: apiService),
        Provider<WebSocketService>.value(value: wsService),

        // Providers
        ChangeNotifierProvider(
          create: (_) =>
              PPKProvider(apiService: apiService, wsService: wsService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              EventProvider(apiService: apiService, wsService: wsService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              StatsProvider(apiService: apiService, wsService: wsService),
        ),
        ChangeNotifierProvider(
          create: (_) => ConfigProvider(apiService: apiService),
        ),
      ],
      child: MaterialApp(
        title: 'CID Ретранслятор',
        theme: AppTheme.lightTheme,
        home: MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
