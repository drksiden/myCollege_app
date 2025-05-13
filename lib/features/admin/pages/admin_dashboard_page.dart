// lib/features/admin/pages/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' as pdf_core;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

// ЗАГЛУШКИ ПРОВАЙДЕРОВ (замените на ваши реальные провайдеры)
final usersCountProvider = Provider<AsyncValue<int>>(
  (ref) => const AsyncData(8),
); // Пример
final groupsCountProvider = Provider<AsyncValue<int>>(
  (ref) => const AsyncData(1),
);
final subjectsCountProvider = Provider<AsyncValue<int>>(
  (ref) => const AsyncData(0),
);
final assignmentsCountProvider = Provider<AsyncValue<int>>(
  (ref) => const AsyncData(0),
);
// КОНЕЦ ЗАГЛУШЕК

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  Future<void> _saveOrDownloadFile({
    required BuildContext context,
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    if (kIsWeb) {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Файл сохранён: $filePath')));
      }
    }
  }

  int _getAsyncValueData(AsyncValue<int> asyncValue, {int defaultValue = 0}) {
    return asyncValue.maybeWhen(
      data: (value) => value,
      orElse: () => defaultValue,
    );
  }

  Future<void> _exportStatsToPdf(BuildContext context, WidgetRef ref) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final headerStyle = pw.TextStyle(
      font: font,
      fontWeight: pw.FontWeight.bold,
      fontSize: 16,
    );
    final cellStyle = pw.TextStyle(font: font, fontSize: 14);
    final pdf = pw.Document();
    final users = _getAsyncValueData(ref.read(usersCountProvider));
    final groups = _getAsyncValueData(ref.read(groupsCountProvider));
    final subjects = _getAsyncValueData(ref.read(subjectsCountProvider));
    final assignments = _getAsyncValueData(ref.read(assignmentsCountProvider));
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context pwContext) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Статистика MyCollege', style: headerStyle),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['Категория', 'Количество'],
                  data: [
                    ['Пользователей', users.toString()],
                    ['Групп', groups.toString()],
                    ['Предметов', subjects.toString()],
                    ['Заданий', assignments.toString()],
                  ],
                  border: pw.TableBorder.all(
                    width: 0.5,
                    color: pdf_core.PdfColors.grey,
                  ),
                  headerStyle: headerStyle,
                  cellStyle: cellStyle,
                  headerDecoration: pw.BoxDecoration(
                    color: pdf_core.PdfColors.grey300,
                  ),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellPadding: const pw.EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                ),
              ],
            ),
      ),
    );
    try {
      final bytes = await pdf.save();
      await _saveOrDownloadFile(
        context: context,
        bytes: bytes,
        filename: 'dashboard_stats.pdf',
        mimeType: 'application/pdf',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка экспорта в PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportStatsToExcel(BuildContext context, WidgetRef ref) async {
    final excel = Excel.createExcel();
    final sheet = excel['Статистика'];
    final users = _getAsyncValueData(ref.read(usersCountProvider));
    final groups = _getAsyncValueData(ref.read(groupsCountProvider));
    final subjects = _getAsyncValueData(ref.read(subjectsCountProvider));
    final assignments = _getAsyncValueData(ref.read(assignmentsCountProvider));
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        .value = TextCellValue('Категория');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
        .value = TextCellValue('Количество');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = TextCellValue('Пользователей');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
        .value = IntCellValue(users);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = TextCellValue('Групп');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
        .value = IntCellValue(groups);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .value = TextCellValue('Предметов');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
        .value = IntCellValue(subjects);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
        .value = TextCellValue('Заданий');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
        .value = IntCellValue(assignments);
    try {
      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception("Ошибка кодирования Excel файла");
      await _saveOrDownloadFile(
        context: context,
        bytes: Uint8List.fromList(fileBytes),
        filename: 'dashboard_stats.xlsx',
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка экспорта в Excel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final usersCount = ref.watch(usersCountProvider);
    final groupsCount = ref.watch(groupsCountProvider);
    final subjectsCount = ref.watch(subjectsCountProvider);
    final assignmentsCount = ref.watch(assignmentsCountProvider);
    final statCardsData = [
      {
        'icon': Icons.people_outline_rounded,
        'label': 'Пользователей',
        'value': usersCount,
        'color': theme.colorScheme.primaryContainer,
        'iconColor': theme.colorScheme.primary,
      },
      {
        'icon': Icons.groups_outlined,
        'label': 'Групп',
        'value': groupsCount,
        'color': theme.colorScheme.secondaryContainer,
        'iconColor': theme.colorScheme.secondary,
      },
      {
        'icon': Icons.library_books_outlined,
        'label': 'Предметов',
        'value': subjectsCount,
        'color': theme.colorScheme.tertiaryContainer,
        'iconColor': theme.colorScheme.tertiary,
      },
      {
        'icon': Icons.assignment_turned_in_outlined,
        'label': 'Заданий',
        'value': assignmentsCount,
        'color': const Color(0xFFE0CFFD),
        'iconColor': const Color(0xFF673AB7),
      },
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dashboard',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.download_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Экспорт статистики',
                onSelected: (value) {
                  if (value == 'pdf') {
                    _exportStatsToPdf(context, ref);
                  } else if (value == 'excel') {
                    _exportStatsToExcel(context, ref);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'pdf',
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf_outlined),
                            SizedBox(width: 8),
                            Text('Экспорт в PDF'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'excel',
                        child: Row(
                          children: [
                            Icon(Icons.table_chart_outlined),
                            SizedBox(width: 8),
                            Text('Экспорт в Excel'),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;
              double childAspectRatio = 2.8;
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 4;
                childAspectRatio = 1.8;
              } else if (constraints.maxWidth > 800) {
                crossAxisCount = 3;
                childAspectRatio = 1.7;
              } else if (constraints.maxWidth > 500) {
                crossAxisCount = 2;
                childAspectRatio = 1.9;
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: statCardsData.length,
                itemBuilder: (context, index) {
                  final data = statCardsData[index];
                  return _StatCard(
                    icon: data['icon'] as IconData,
                    label: data['label'] as String,
                    value: data['value'] as AsyncValue<int>,
                    color: data['color'] as Color,
                    iconColor: data['iconColor'] as Color,
                    delay: index * 120,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final AsyncValue<int> value;
  final Color color;
  final Color iconColor;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return value.when(
      loading:
          () => _ShimmerCard(color: color)
              .animate()
              .fadeIn(duration: 350.ms, delay: delay.ms)
              .slideX(
                begin: -0.05,
                duration: 350.ms,
                delay: delay.ms,
                curve: Curves.easeOut,
              ),
      error:
          (e, _) => Material(
            elevation: 0.5,
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.errorContainer,
            child: Container(
              height: 110,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      data:
          (count) => _AnimatedCountCard(
                icon: icon,
                label: label,
                count: count,
                cardColor: color,
                iconAndTextColor: iconColor,
                delay: delay,
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: delay.ms)
              .slideX(
                begin: -0.05,
                duration: 400.ms,
                delay: delay.ms,
                curve: Curves.easeOut,
              )
              .then(delay: 50.ms)
              .scaleXY(begin: 0.98, duration: 350.ms, curve: Curves.elasticOut),
    );
  }
}

class _AnimatedCountCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color cardColor;
  final Color iconAndTextColor;
  final int delay;

  const _AnimatedCountCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.cardColor,
    required this.iconAndTextColor,
    required this.delay,
  });

  @override
  State<_AnimatedCountCard> createState() => _AnimatedCountCardState();
}

class _AnimatedCountCardState extends State<_AnimatedCountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimDouble;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _countAnimDouble = Tween<double>(
      begin: 0,
      end: widget.count.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delay + 400), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedCountCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _countAnimDouble = Tween<double>(
        begin: 0,
        end: widget.count.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      Future.delayed(Duration(milliseconds: widget.delay + 400), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color textColor = widget.iconAndTextColor;
    return Material(
      elevation: 1.5,
      borderRadius: BorderRadius.circular(12),
      color: widget.cardColor,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withAlpha(204),
              radius: 22,
              child: Icon(widget.icon, color: textColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedBuilder(
                    animation: _countAnimDouble,
                    builder:
                        (context, child) => Text(
                          _countAnimDouble.value.toInt().toString(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final Color color;
  const _ShimmerCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(12),
          color: color,
          child: Container(
            height: 110,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(backgroundColor: Colors.grey.shade300, radius: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 1300.ms,
          color: Colors.grey.shade100.withAlpha(100),
          blendMode: BlendMode.srcOver,
        );
  }
}
