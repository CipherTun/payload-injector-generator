import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PayloadShell extends StatelessWidget {
  const PayloadShell({required this.child, super.key});
  final Widget child;

  static const destinations = [
    ('/home', Icons.space_dashboard_rounded, 'Home'),
    ('/studio', Icons.auto_awesome_rounded, 'Studio'),
    ('/editor', Icons.terminal_rounded, 'Editor'),
    ('/templates', Icons.layers_rounded, 'Templates'),
    ('/history', Icons.history_rounded, 'History'),
  ];

  int _index(String location) {
    final index = destinations.indexWhere((d) => location.startsWith(d.$1));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _index(location);
    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (value) => context.go(destinations[value].$1),
              backgroundColor: const Color(0xCC11131B),
              indicatorColor: const Color(0x337C5CFF),
              height: 72,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(icon: Icon(d.$2), label: d.$3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
