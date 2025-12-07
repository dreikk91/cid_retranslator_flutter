import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cid_retranslator/theme/constants.dart';
import 'package:cid_retranslator/providers/stats_provider.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, statsProvider, child) {
        final stats = statsProvider.stats;

        return Container(
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.statusBarBg,
            border: Border(
              top: BorderSide(color: AppColors.win11Border, width: 1),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              // Connection status
              _buildStatusIndicator(stats.connected),
              _buildSeparator(),

              // Accepted counter
              _buildCounter(
                '✓',
                stats.accepted.toString(),
                AppColors.counterAcceptedIcon,
              ),
              _buildSeparator(),

              // Rejected counter
              _buildCounter(
                '✗',
                stats.rejected.toString(),
                AppColors.counterRejectedIcon,
              ),
              _buildSeparator(),

              // Reconnects counter
              _buildCounter(
                '↻',
                'Повтори: ${stats.reconnects}',
                AppColors.counterReconnectIcon,
              ),
              _buildSeparator(),

              // Uptime
              _buildCounter('⏱', stats.uptime, AppColors.counterUptimeIcon),

              Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(bool connected) {
    return Row(
      children: [
        Text(
          '●',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: connected
                ? AppColors.statusConnectedBg
                : AppColors.statusDisconnectedBg,
          ),
        ),
        SizedBox(width: 6),
        Text(
          connected ? 'Підключено' : 'Відключено',
          style: TextStyle(fontSize: 9, color: AppColors.statusBarText),
        ),
      ],
    );
  }

  Widget _buildCounter(String icon, String text, Color iconColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            icon,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 9, color: AppColors.statusBarText),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(width: 1, height: 24, color: AppColors.statusBarSeparator);
  }
}
