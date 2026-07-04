import 'package:cliq/shared/data/database.dart';
import 'package:flutter/cupertino.dart';

class ConnectionIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final double borderRadius;
  final double? size;
  final double? padding;

  const ConnectionIcon({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.borderRadius = 6,
    this.size,
    this.padding,
  });

  ConnectionIcon.fromConnection(
    Connection connection, {
    super.key,
    this.borderRadius = 6,
    this.size,
    this.padding,
  }) : icon = connection.icon.iconData,
       iconColor = connection.iconColor,
       iconBackgroundColor = connection.iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: .circular(borderRadius),
      ),
      padding: EdgeInsets.all(padding ?? 4),
      child: Icon(icon, color: iconColor, size: size),
    );
  }
}
