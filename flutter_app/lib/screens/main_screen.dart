import 'package:flutter/material.dart';
import 'package:cid_retranslator/screens/ppk_tab.dart';
import 'package:cid_retranslator/screens/events_tab.dart';
import 'package:cid_retranslator/screens/settings_tab.dart';
import 'package:cid_retranslator/widgets/stats_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CID Ретранслятор - Система моніторингу'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'ППК'),
            Tab(text: 'Події'),
            Tab(text: 'Налаштування'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [PPKTab(), EventsTab(), SettingsTab()],
            ),
          ),
          // Status bar at bottom
          StatsBar(),
        ],
      ),
    );
  }
}
