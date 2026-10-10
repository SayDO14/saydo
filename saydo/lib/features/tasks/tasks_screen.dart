import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_format.dart';
import 'task_edit_sheet.dart';
import 'task_item.dart';
import 'tasks_repository.dart';

// ─── Couleurs du thème ───────────────────────────────────────────────────────
const _bgColor = Color(0xFF070818);
const _cardColor = Color(0xFF0F1230);
const _cardBorder = Color(0xFF1E2455);
const _accentBlue = Color(0xFF2563EB);
const _accentNeon = Color(0xFF3B82F6);
const _textPrimary = Colors.white;
const _textSecondary = Color(0xFF8B9CC7);
const _todoColor = Color(0xFF3B82F6);
const _doneColor = Color(0xFF10B981);

// ─── Filtre de l'écran ───────────────────────────────────────────────────────
enum _Filter { all, todo, done }

// ─── Screen ─────────────────────────────────────────────────────────────────
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  _Filter _filter = _Filter.all;

  Future<void> _toggleDone(TaskItem task, bool isDone) async {
    try {
      await ref.read(tasksRepositoryProvider).toggleDone(task.id, isDone);
      ref.invalidate(tasksProvider);
    } catch (e) {
      if (mounted) _showError('Impossible de mettre à jour la tâche : $e');
    }
  }

  Future<void> _delete(TaskItem task) async {
    final ok = await _confirmDelete(task);
    if (ok != true) return;
    try {
      await ref.read(tasksRepositoryProvider).delete(task.id);
      ref.invalidate(tasksProvider);
    } catch (e) {
      if (mounted) _showError('Impossible de supprimer : $e');
    }
  }

  Future<bool?> _confirmDelete(TaskItem task) => showDialog<bool>(
        context: context,
        builder: (_) => _GlassDialog(
          title: 'Supprimer la tâche ?',
          body: '"${task.title}" sera supprimée définitivement.',
          confirmLabel: 'Supprimer',
          confirmColor: Colors.redAccent,
        ),
      );

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          _AnimatedBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildFilterTabs(),
                const SizedBox(height: 8),
                _buildNewTaskButton(context),
                const SizedBox(height: 8),
                Expanded(
                  child: tasks.when(
                    loading: () => _buildLoading(),
                    error: (e, _) => _buildError(e),
                    data: (items) => _buildList(items),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MES TÂCHES',
                style: TextStyle(
                  color: _accentNeon,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Mes tâches',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          _GlassIconButton(
            icon: Icons.tune_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            _FilterTab(
              label: 'Toutes',
              active: _filter == _Filter.all,
              onTap: () => setState(() => _filter = _Filter.all),
            ),
            _FilterTab(
              label: 'À faire',
              active: _filter == _Filter.todo,
              onTap: () => setState(() => _filter = _Filter.todo),
            ),
            _FilterTab(
              label: 'Terminées',
              active: _filter == _Filter.done,
              onTap: () => setState(() => _filter = _Filter.done),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTaskButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => showTaskEditSheet(
          context,
          TaskItem(id: '', title: '', status: 'todo'),
        ),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _accentBlue.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Nouvelle tâche',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<TaskItem> items) {
    final filtered = switch (_filter) {
      _Filter.all => items,
      _Filter.todo => items.where((t) => !t.isDone).toList(),
      _Filter.done => items.where((t) => t.isDone).toList(),
    };

    if (filtered.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      onRefresh: () => ref.refresh(tasksProvider.future),
      color: _accentNeon,
      backgroundColor: _cardColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: filtered.length,
        itemBuilder: (_, i) => _TaskCard(
          task: filtered[i],
          onToggleDone: (val) => _toggleDone(filtered[i], val),
          onDelete: () => _delete(filtered[i]),
          onTap: () => showTaskEditSheet(context, filtered[i]),
        ),
      ),
    );
  }

  Widget _buildLoading() => const Center(
        child: CircularProgressIndicator(color: _accentNeon, strokeWidth: 2),
      );

  Widget _buildError(Object e) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: _textSecondary, size: 48),
            const SizedBox(height: 12),
            Text('Erreur de chargement\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary)),
            const SizedBox(height: 16),
            _PillButton(
              label: 'Réessayer',
              onTap: () => ref.invalidate(tasksProvider),
            ),
          ],
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentBlue.withOpacity(0.1),
                border: Border.all(color: _accentBlue.withOpacity(0.3)),
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: _accentNeon, size: 38),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune tâche pour le moment',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dictez-en une avec le micro',
              style: TextStyle(color: _textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
}

// ─── Task card ───────────────────────────────────────────────────────────────
class _TaskCard extends StatefulWidget {
  const _TaskCard({
    required this.task,
    required this.onToggleDone,
    required this.onDelete,
    required this.onTap,
  });

  final TaskItem task;
  final ValueChanged<bool> onToggleDone;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDone = task.isDone;

    String dateLabel = '';
    if (task.dueAt != null) {
      dateLabel = formatDayLabel(task.dueAt!);
      if (task.dueHasTime) {
        dateLabel += ' · ${formatClock(task.dueAt!)}';
      }
    }

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDone ? _doneColor.withOpacity(0.3) : _cardBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: () => widget.onToggleDone(!isDone),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? _doneColor.withOpacity(0.15)
                              : Colors.transparent,
                          border: Border.all(
                            color: isDone ? _doneColor : _textSecondary,
                            width: 2,
                          ),
                        ),
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                                size: 15, color: _doneColor)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              color: isDone ? _textSecondary : _textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: _textSecondary,
                            ),
                          ),
                          if (dateLabel.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 11, color: _textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  dateLabel,
                                  style: const TextStyle(
                                      color: _textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status badge
                    _StatusBadge(isDone: isDone),
                    const SizedBox(width: 6),
                    // Arrow
                    const Icon(Icons.chevron_right_rounded,
                        color: _textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Status badge ────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isDone});
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone
            ? _doneColor.withOpacity(0.15)
            : _todoColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone
              ? _doneColor.withOpacity(0.5)
              : _todoColor.withOpacity(0.5),
        ),
      ),
      child: Text(
        isDone ? 'Terminée' : 'À faire',
        style: TextStyle(
          color: isDone ? _doneColor : _todoColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Filter tab ──────────────────────────────────────────────────────────────
class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _accentBlue.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : _textSecondary,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Glass icon button ────────────────────────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Icon(icon, color: _textSecondary, size: 20),
      ),
    );
  }
}

// ─── Pill button ─────────────────────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─── Glass dialog ─────────────────────────────────────────────────────────────
class _GlassDialog extends StatelessWidget {
  const _GlassDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF131533),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary, fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _cardBorder),
                      foregroundColor: _textSecondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated background ─────────────────────────────────────────────────────
class _AnimatedBackground extends StatefulWidget {
  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _BgPainter(_ctrl.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  _BgPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF1D4ED8).withOpacity(0.12 + 0.04 * t);
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * (0.05 + 0.05 * t)),
        size.width * 0.4,
        paint);

    paint.color = const Color(0xFF312E81).withOpacity(0.15 + 0.05 * t);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * (0.7 + 0.1 * t)),
        size.width * 0.45,
        paint);
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}
