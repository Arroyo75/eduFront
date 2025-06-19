import 'package:flutter/material.dart';
import '../services/settings.dart';
import '../services/progress.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final SettingsService _settingsService = SettingsService();
  bool _bypassLocks = false;
  bool _debugMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _bypassLocks = _settingsService.bypassLocks;
      _debugMode = _settingsService.debugMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings, color: Colors.blue),
          SizedBox(width: 8),
          Text('Settings'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Bypass Locks'),
            subtitle: const Text('Unlock all technologies and sections'),
            value: _bypassLocks,
            onChanged: (value) async {
              await _settingsService.setBypassLocks(value);
              setState(() {
                _bypassLocks = value;
              });
            },
            secondary: const Icon(Icons.lock_open),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Debug Mode'),
            subtitle: const Text('Show additional developer information'),
            value: _debugMode,
            onChanged: (value) async {
              await _settingsService.setDebugMode(value);
              setState(() {
                _debugMode = value;
              });
            },
            secondary: const Icon(Icons.bug_report),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            final success = await ProgressService().forceSyncToCloud();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'Sync successful!' : 'Sync failed'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          },
          child: Text('Test API Sync'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (_bypassLocks || _debugMode) ...[
          TextButton(
            onPressed: () async {
              await _settingsService.setBypassLocks(false);
              await _settingsService.setDebugMode(false);
              setState(() {
                _bypassLocks = false;
                _debugMode = false;
              });
            },
            child: const Text('Reset All'),
          ),
        ],
      ],
    );
  }
}