import 'package:flutter/material.dart';

class ActionLog {
  final IconData icon;
  final Color? iconColor;
  final String description;
  final DateTime timestamp;

  const ActionLog({
    required this.icon,
    this.iconColor,
    required this.description,
    required this.timestamp,
  });
}