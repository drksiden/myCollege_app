import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../providers/teacher_schedule_provider.dart';
import '../providers/journal_providers.dart';

class ScheduleExportService {
  static Future<void> exportToPdf(
    BuildContext context,
    WidgetRef ref,
    String? groupId,
    String? subject,
  ) async {
    final pdf = pw.Document();
    final scheduleEntries = await ref.read(teacherScheduleProvider.future);
    final groupsInfoList = await ref.read(
      teacherSubjectsAndGroupsProvider.future,
    );
    final groupsMap = {for (var group in groupsInfoList) group.id: group.name};
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header:
            (pwContext) => pw.Header(
              level: 0,
              child: pw.Text(
                'Расписание занятий',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
        build:
            (pwContext) => [
              ...dayNames.asMap().entries.map((entry) {
                final dayIndexInLoop = entry.key + 1;
                final dayName = entry.value;
                final dayLessons =
                    scheduleEntries
                        .where(
                          (lesson) =>
                              lesson.dayOfWeek == dayIndexInLoop &&
                              (groupId == null || lesson.groupId == groupId) &&
                              (subject == null || lesson.subject == subject),
                        )
                        .toList()
                      ..sort(
                        (a, b) => a.lessonNumber.compareTo(b.lessonNumber),
                      );
                if (dayLessons.isEmpty) return pw.Container();
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8),
                      child: pw.Text(
                        dayName,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.TableHelper.fromTextArray(
                      headers: ['№', 'Время', 'Предмет', 'Группа', 'Аудитория'],
                      data:
                          dayLessons
                              .map(
                                (lesson) => [
                                  lesson.lessonNumber.toString(),
                                  '${lesson.startTime}-${lesson.endTime}',
                                  lesson.subject,
                                  lesson.groupId != null
                                      ? (groupsMap[lesson.groupId] ??
                                          lesson.groupId!)
                                      : '',
                                  lesson.classroom ?? '',
                                ],
                              )
                              .toList(),
                      border: pw.TableBorder.all(
                        width: 0.5,
                        color: PdfColors.grey,
                      ),
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      cellAlignment: pw.Alignment.centerLeft,
                      cellPadding: const pw.EdgeInsets.all(4),
                    ),
                    pw.SizedBox(height: 15),
                  ],
                );
              }),
            ],
      ),
    );
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/schedule_export.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Расписание занятий',
          subject: 'Расписание PDF',
          sharePositionOrigin:
              box != null
                  ? box.localToGlobal(Offset.zero) & box.size
                  : const Rect.fromLTWH(0, 0, 100, 100),
        ),
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

  static Future<void> exportToExcel(
    BuildContext context,
    WidgetRef ref,
    String? groupId,
    String? subject,
  ) async {
    final excel = Excel.createExcel();
    final scheduleEntries = await ref.read(teacherScheduleProvider.future);
    final groupsInfoList = await ref.read(
      teacherSubjectsAndGroupsProvider.future,
    );
    final groupsMap = {for (var group in groupsInfoList) group.id: group.name};
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];
    bool hasDataForExcel = false;

    for (var i = 0; i < dayNames.length; i++) {
      final dayIndexInLoop = i + 1;
      final dayName = dayNames[i];
      final dayLessons =
          scheduleEntries
              .where(
                (lesson) =>
                    lesson.dayOfWeek == dayIndexInLoop &&
                    (groupId == null || lesson.groupId == groupId) &&
                    (subject == null || lesson.subject == subject),
              )
              .toList()
            ..sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
      if (dayLessons.isEmpty) continue;
      hasDataForExcel = true;
      Sheet sheetObject = excel[dayName];
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = TextCellValue('№');
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = TextCellValue('Время');
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = TextCellValue('Предмет');
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = TextCellValue('Группа');
      sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
          .value = TextCellValue('Аудитория');
      for (var j = 0; j < dayLessons.length; j++) {
        final lesson = dayLessons[j];
        final rowIndex = j + 1;
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex),
            )
            .value = TextCellValue(lesson.lessonNumber.toString());
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex),
            )
            .value = TextCellValue('${lesson.startTime}-${lesson.endTime}');
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex),
            )
            .value = TextCellValue(lesson.subject);
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex),
            )
            .value = TextCellValue(
          lesson.groupId != null
              ? (groupsMap[lesson.groupId] ?? lesson.groupId!)
              : '',
        );
        sheetObject
            .cell(
              CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex),
            )
            .value = TextCellValue(lesson.classroom ?? '');
      }
    }
    if (!hasDataForExcel) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Нет данных для экспорта в Excel.')),
      );
      return;
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileBytes = excel.encode();
      if (fileBytes == null) throw Exception("Ошибка кодирования Excel файла");
      final filePath = '${directory.path}/schedule_export.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Расписание занятий',
          subject: 'Расписание Excel',
          sharePositionOrigin:
              box != null
                  ? box.localToGlobal(Offset.zero) & box.size
                  : const Rect.fromLTWH(0, 0, 100, 100),
        ),
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
}
