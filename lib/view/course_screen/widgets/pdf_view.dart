import 'package:e_learning/core/models/lesson_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:screen_protector/screen_protector.dart';

class PdfView extends StatefulWidget {
  final LessonModel lesson;

  const PdfView({super.key, required this.lesson});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  late PDFViewController _pdfController;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ScreenProtector.preventScreenshotOn();
    ScreenProtector.protectDataLeakageOn();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ScreenProtector.preventScreenshotOff(); // افصل الحماية لما تخرج من الصفحة
    ScreenProtector.protectDataLeakageOff(); // افصل الحماية لما تخرج من الصفحة
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.lesson.name),
      ),
      body: Stack(
        children: [
          PDF(

            onViewCreated: (controller) {
              _pdfController = controller;
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? 0;
                _isReady = true;
              });
            },
            onError: (error) {
              print("PDF Error: $error");
            },
            pageFling: true,
            pageSnap: true,
            swipeHorizontal: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ ديناميكي
          ).cachedFromUrl(
            convertToDirectLink(widget.lesson.pdf_url!),
            placeholder: (progress) =>
                Center(child: Text('جاري التحميل... ${progress ?? 0}%')),
            errorWidget: (error) =>
                Center(child: Text('حدث خطأ: $error')),
          ),

          if (_isReady)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Slider(
                    value: _currentPage.toDouble(),
                    min: 0,
                    max: (_totalPages > 1 ? _totalPages - 1 : 1).toDouble(),
                    divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                    label: 'صفحة ${_currentPage + 1} من $_totalPages',
                    onChanged: (value) {
                      setState(() {
                        _currentPage = value.toInt();
                      });
                      _pdfController.setPage(_currentPage);
                    },
                  ),
                  Text(
                    'الصفحة ${_currentPage + 1} من $_totalPages',
                    style: TextStyle(color: textColor), // ✅ ديناميكي
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  String convertToDirectLink(String normalUrl) {
    final uri = Uri.parse(normalUrl);
    final segments = uri.pathSegments;

    if (segments.contains('d') && segments.length >= 3) {
      final fileId = segments[2];
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }

    throw FormatException('الرابط غير صالح أو لا يمكن تحويله');
  }
}
