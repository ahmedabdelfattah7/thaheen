import 'package:flutter/material.dart';

import 'message_view.dart';

/// Friendly "nothing here" message.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return MessageView(icon: icon, title: message);
  }
}
