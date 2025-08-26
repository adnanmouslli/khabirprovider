// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'dart:io';
//
// class PDFViewerWithDownload extends StatefulWidget {
//   final String pdfUrl;
//   final String title;
//
//   const PDFViewerWithDownload({
//     super.key,
//     required this.pdfUrl,
//     required this.title,
//   });
//
//   @override
//   State<PDFViewerWithDownload> createState() => _PDFViewerWithDownloadState();
// }
//
// class _PDFViewerWithDownloadState extends State<PDFViewerWithDownload> {
//   String? localPDFPath;
//   bool isLoading = true;
//   String loadingText = 'جاري التحميل...';
//   double downloadProgress = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _downloadAndOpenPDF();
//   }
//
//   Future<void> _downloadAndOpenPDF() async {
//     try {
//       setState(() {
//         isLoading = true;
//         loadingText = 'جاري تحميل المستند...';
//         downloadProgress = 0.0;
//       });
//
//       // إنشاء مجلد مؤقت
//       final dir = await getTemporaryDirectory();
//       final fileName = widget.pdfUrl.split('/').last;
//       final file = File('${dir.path}/$fileName');
//
//       // تحميل الملف
//       final request = http.Request('GET', Uri.parse(widget.pdfUrl));
//       final response = await request.send();
//
//       if (response.statusCode == 200) {
//         final contentLength = response.contentLength ?? 0;
//         int downloadedBytes = 0;
//
//         final sink = file.openWrite();
//
//         await response.stream.listen(
//               (chunk) {
//             sink.add(chunk);
//             downloadedBytes += chunk.length;
//
//             if (contentLength > 0) {
//               setState(() {
//                 downloadProgress = downloadedBytes / contentLength;
//                 loadingText = 'جاري التحميل... ${(downloadProgress * 100).toInt()}%';
//               });
//             }
//           },
//           onDone: () async {
//             await sink.close();
//             setState(() {
//               localPDFPath = file.path;
//               isLoading = false;
//             });
//           },
//           onError: (error) {
//             sink.close();
//             _showError('فشل في تحميل المستند');
//           },
//         );
//       } else {
//         _showError('خطأ في الخادم: ${response.statusCode}');
//       }
//     } catch (e) {
//       _showError('خطأ في التحميل: $e');
//     }
//   }
//
//   void _showError(String message) {
//     setState(() {
//       isLoading = false;
//     });
//
//     Get.snackbar(
//       'خطأ',
//       message,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//
//     // العودة للشاشة السابقة
//     Get.back();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//         actions: [
//           if (!isLoading)
//             IconButton(
//               icon: const Icon(Icons.share),
//               onPressed: () => _sharePDF(),
//             ),
//         ],
//       ),
//       body: isLoading
//           ? Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text(loadingText),
//             if (downloadProgress > 0) ...[
//               const SizedBox(height: 16),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 32),
//                 child: LinearProgressIndicator(value: downloadProgress),
//               ),
//             ],
//           ],
//         ),
//       )
//           : localPDFPath != null
//           ? PDFView(
//         filePath: localPDFPath!,
//         enableSwipe: true,
//         swipeHorizontal: false,
//         autoSpacing: false,
//         pageFling: false,
//         onRender: (pages) {
//           print('PDF تحتوي على $pages صفحة');
//         },
//         onError: (error) {
//           print('خطأ في عرض PDF: $error');
//           _showError('خطأ في عرض المستند');
//         },
//         onPageError: (page, error) {
//           print('خطأ في الصفحة $page: $error');
//         },
//       )
//           : const Center(
//         child: Text('فشل في تحميل المستند'),
//       ),
//     );
//   }
//
//   void _sharePDF() {
//     // يمكن إضافة منطق المشاركة هنا
//     Get.snackbar(
//       'مشاركة',
//       'سيتم مشاركة المستند',
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//     );
//   }
//
//   @override
//   void dispose() {
//     // حذف الملف المؤقت عند الخروج
//     if (localPDFPath != null) {
//       final file = File(localPDFPath!);
//       if (file.existsSync()) {
//         file.deleteSync();
//       }
//     }
//     super.dispose();
//   }
// }