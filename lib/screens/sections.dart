import 'package:flutter/material.dart';
import '../models/technology.dart';
import '../models/section.dart';
import '../widgets/section/section_card.dart';
import '../widgets/section/technology_header.dart';
import '../widgets/settings_dialog.dart';
import '../services/settings.dart';
import '../services/progress.dart';
import 'lessons.dart';
import 'quiz.dart';

class SectionsScreen extends StatefulWidget {
  final Technology technology;
  final VoidCallback? onTechnologyProgressChanged;

  const SectionsScreen({
    Key? key,
    required this.technology,
    this.onTechnologyProgressChanged,
  }) : super(key: key);

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late ScrollController _scrollController;
  final SettingsService _settingsService = SettingsService();
  final ProgressService _progressService = ProgressService();

  bool _isHeaderExpanded = true;
  int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scrollController = ScrollController()
      ..addListener(_onScroll);

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _settingsService.init();
    await _progressService.init();

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listAnimationController.forward();
    });
  }

  void _onScroll() {
    const threshold = 100.0;
    final isExpanded = _scrollController.offset < threshold;

    if (isExpanded != _isHeaderExpanded) {
      setState(() {
        _isHeaderExpanded = isExpanded;
      });
    }
  }

  void _forceRefresh() { //forces refresh on all section cards
    setState(() {
      _refreshCounter++;
    });

    widget.onTechnologyProgressChanged?.call();
  }

  Future<void> _checkAndUnlockNext(Section completedSection) async {
    final completedLessons = _progressService.getSectionProgress(widget.technology.id, completedSection.id);
    final testCompleted = _progressService.isSectionTestCompleted(widget.technology.id, completedSection.id);

    if (completedLessons < completedSection.totalLessons || !testCompleted) {
      return; //not actually completed
    }

    final currentIndex = widget.technology.sections.indexWhere((s) => s.id == completedSection.id);

    if (currentIndex == -1) return;

    //unlocks next section if it exists
    if (currentIndex < widget.technology.sections.length - 1) {
      final nextSection = widget.technology.sections[currentIndex + 1];
      await _progressService.unlockSection(widget.technology.id, nextSection.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔓 ${nextSection.title} unlocked!'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      _forceRefresh();

    } else {
      //if it was last section unlocks tech
      await _unlockNextTechnology();
    }
  }

  Future<void> _unlockNextTechnology() async {

    final Map<String, String> technologyProgression = {
      'html': 'css',
      'css': 'javascript',
      'javascript': 'react',
    };

    final nextTechnologyId = technologyProgression[widget.technology.id];

    if (nextTechnologyId != null) {
      await _progressService.unlockTechnology(nextTechnologyId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ${widget.technology.name} completed! Next technology unlocked!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      _forceRefresh();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🏆 Congratulations! All technologies completed!'),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  bool _shouldSectionBeUnlocked(Section section) {
    //first section of first technology is always unlocked
    if (section.id == widget.technology.sections.first.id) {
      return true;
    }

    if (_progressService.isSectionUnlockedByProgress(widget.technology.id, section.id)) {
      return true;
    }

    final currentIndex = widget.technology.sections.indexWhere((s) => s.id == section.id);
    if (currentIndex <= 0) return !section.isLocked;

    final previousSection = widget.technology.sections[currentIndex - 1];

    final prevCompletedLessons = _progressService.getSectionProgress(widget.technology.id, previousSection.id);
    final prevTestCompleted = _progressService.isSectionTestCompleted(widget.technology.id, previousSection.id);

    final previousSectionCompleted = prevCompletedLessons >= previousSection.totalLessons && prevTestCompleted;

    return previousSectionCompleted || !section.isLocked;
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: widget.technology.gradientColors.first,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _forceRefresh,
                tooltip: 'Refresh Progress',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showSettingsDialog(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: AnimatedOpacity(
                opacity: _isHeaderExpanded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  widget.technology.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.technology.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _headerAnimationController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _headerAnimationController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: TechnologyHeader(
                        technology: widget.technology,
                        progressService: _progressService,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          if (_settingsService.bypassLocks) ...[
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await ProgressService().resetAllProgress();
                        setState(() {});
                      },
                      child: Text('RESET DEMO'),
                    ),
                    Icon(Icons.lock_open, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bypass Mode: All sections are unlocked for testing',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          //section list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: AnimatedBuilder(
              animation: _listAnimationController,
              builder: (context, child) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final section = widget.technology.sections[index];

                      final effectiveSection = _settingsService.bypassLocks
                          ? Section( //bypassed
                        id: section.id,
                        title: section.title,
                        description: section.description,
                        totalLessons: section.totalLessons,
                        completedLessons: section.completedLessons,
                        finalTestCompleted: section.finalTestCompleted,
                        isLocked: false, //unlocked
                        prerequisites: section.prerequisites,
                        icon: section.icon,
                        estimatedTime: section.estimatedTime,
                      )
                          : Section( //standard
                        id: section.id,
                        title: section.title,
                        description: section.description,
                        totalLessons: section.totalLessons,
                        completedLessons: section.completedLessons,
                        finalTestCompleted: section.finalTestCompleted,
                        isLocked: !_shouldSectionBeUnlocked(section), //dynamic lock check
                        prerequisites: section.prerequisites,
                        icon: section.icon,
                        estimatedTime: section.estimatedTime,
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
                          child: SectionCard(
                            key: ValueKey('section_${section.id}_$_refreshCounter'),
                            section: effectiveSection,
                            technologyColors: widget.technology.gradientColors,
                            technologyId: widget.technology.id,
                            refreshKey: ValueKey(_refreshCounter),
                            onSectionCompleted: _checkAndUnlockNext,
                            onProgressChanged: _forceRefresh,
                            onTap: () => _onSectionTap(effectiveSection),
                            onTestTap: () => _onSectionTestTap(effectiveSection),
                          ),
                        ),
                      );
                    },
                    childCount: widget.technology.sections.length,
                  ),
                );
              },
            ),
          ),

          //padding from bottom
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  void _onSectionTap(Section section) {
    if (section.isLocked && !_settingsService.bypassLocks) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonsScreen(
          technology: widget.technology,
          section: section,
        ),
      ),
    ).then((_) {
      print('Returned from lessons, forcing refresh');
      _forceRefresh();
    });
  }

  void _onSectionTestTap(Section section) async {
    //check if all lessons are completed
    final completedLessons = _progressService.getSectionProgress(widget.technology.id, section.id);
    final lessonsCompleted = completedLessons >= section.totalLessons;

    if (!lessonsCompleted && !_settingsService.bypassLocks) {
      return; //test locked
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          technology: widget.technology,
          section: section,
        ),
      ),
    ).then((_) async {
      print('returned from quiz');

      //if quiz completed unlock
      await _checkAndUnlockNext(section);

      _forceRefresh();
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SettingsDialog(),
    ).then((_) {
      _forceRefresh();
    });
  }
}