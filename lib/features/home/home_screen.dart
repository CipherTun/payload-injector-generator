import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../domain/payload.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PayloadLab', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('Studio', style: TextStyle(fontSize: 12, color: Colors.white54)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
        children: [
          _HeroCard(onTap: () => context.go('/studio')),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'Saved', value: history.value?.length.toString() ?? '—')),
              const SizedBox(width: 12),
              const Expanded(child: _StatCard(label: 'Offline', value: '100%')),
            ],
          ),
          const SizedBox(height: 26),
          const _SectionTitle(title: 'Quick actions'),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.auto_awesome_rounded,
            title: 'Open Studio',
            subtitle: 'Build a request from structured fields',
            onTap: () => context.go('/studio'),
          ),
          _ActionTile(
            icon: Icons.terminal_rounded,
            title: 'Open Editor',
            subtitle: 'Inspect and transform raw text',
            onTap: () => context.go('/editor'),
          ),
          _ActionTile(
            icon: Icons.layers_rounded,
            title: 'Browse Templates',
            subtitle: 'Start from a reusable local template',
            onTap: () => context.go('/templates'),
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: 'Recent work'),
          const SizedBox(height: 10),
          if (history.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (history.value?.isEmpty ?? true)
            const _EmptyCard()
          else
            for (final entry in (history.value ?? const <HistoryEntry>[]).take(4))
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: const CircleAvatar(child: Icon(Icons.code_rounded, size: 18)),
                title: Text(entry.title),
                subtitle: Text(entry.payload.replaceAll('\r\n', ' · '), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF34256D), Color(0xFF141827)],
            ),
            border: Border.all(color: const Color(0x557C5CFF)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded, size: 30),
              SizedBox(height: 24),
              Text('Payload Studio', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text('Construct, inspect and validate request templates locally.'),
              SizedBox(height: 22),
              Row(children: [Text('Start building'), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, size: 18)]),
            ],
          ),
        ),
      );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white54)),
          ]),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800));
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(backgroundColor: const Color(0x227C5CFF), child: Icon(icon)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            Icon(Icons.inbox_rounded, size: 38, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            const Text('Nothing saved yet', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Generated work will appear here.', style: TextStyle(color: Colors.white54)),
          ]),
        ),
      );
}
