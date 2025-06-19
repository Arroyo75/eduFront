import 'package:flutter/material.dart';
import '../models/technology.dart';
import '../widgets/technology/technology_card.dart';
import '../widgets/settings_dialog.dart';
import '../data/sample_data.dart';
import '../services/settings.dart';
import '../services/progress.dart';
import '../screens/sections.dart';

class TechnologiesScreen extends StatefulWidget {
  final VoidCallback? onTechnologyProgressChanged;

  const TechnologiesScreen({
    Key? key,
    this.onTechnologyProgressChanged,
  }) : super(key: key);

  @override
  State<TechnologiesScreen> createState() => _TechnologiesScreenState();
}

class _TechnologiesScreenState extends State<TechnologiesScreen>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  List<Technology>? technologies; //nullable to handle initialization
  final SettingsService _settingsService = SettingsService();
  final ProgressService _progressService = ProgressService();
  bool _isInitialized = false;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _settingsService.init();
      await _progressService.init();

      technologies = SampleData.getTechnologies();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) { //widget could have been removed
            _listAnimationController.forward();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          technologies = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  bool _shouldTechnologyBeUnlocked(Technology technology) {
    if (technology.id == 'html') return true;

    return _progressService.isTechnologyUnlockedByProgress(technology.id) || !technology.isLocked;
  }

  void _forceRefresh() {
    setState(() {
      _refreshCounter++;
      print('Forced tech refresh: $_refreshCounter');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Technology',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade900, Colors.purple.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Debug info banner
              if (_isInitialized && _settingsService.bypassLocks) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.orange.shade100,
                  child: Row(
                    children: [
                      Icon(Icons.lock_open, color: Colors.orange.shade700, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Bypass Mode: All content unlocked',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized || technologies == null) { //loading state
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading technologies...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (technologies!.isEmpty) { //empty state if no technologies
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No technologies available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: technologies!.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final technology = technologies![index];

            final effectiveTechnology = _settingsService.bypassLocks
                ? Technology(
              id: technology.id,
              name: technology.name,
              description: technology.description,
              icon: technology.icon,
              gradientColors: technology.gradientColors,
              sections: technology.sections,
              prerequisites: technology.prerequisites,
              isLocked: false,
            )
                : Technology(
              id: technology.id,
              name: technology.name,
              description: technology.description,
              icon: technology.icon,
              gradientColors: technology.gradientColors,
              sections: technology.sections,
              prerequisites: technology.prerequisites,
              isLocked: !_shouldTechnologyBeUnlocked(technology),
            );

            final animationDelay = index * 0.1;
            final animation = CurvedAnimation(
              parent: _listAnimationController,
              curve: Interval(
                animationDelay,
                (animationDelay + 0.4).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: TechnologyCard(
                  technology: effectiveTechnology,
                  progressService: _progressService, // Pass the progress service here
                  onTap: () => _onTechnologyTap(effectiveTechnology),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _onTechnologyTap(Technology technology) {
    if (technology.isLocked && !_settingsService.bypassLocks) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectionsScreen(
          technology: technology,
          onTechnologyProgressChanged: () {
            _forceRefresh();
          },
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SettingsDialog(),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }
}