// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// class PDFViewer extends StatefulWidget {
//   static const String routeName = 'pdf_viewer';

//   const PDFViewer({Key? key}) : super(key: key);

//   @override
//   _PDFViewerState createState() => _PDFViewerState();
// }

// class _PDFViewerState extends State<PDFViewer> {
//   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
//   String url = "";
//   String topicname = "PDF Viewer";

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () {
//       dynamic doc = ModalRoute.of(context)!.settings.arguments;
//       var courseId = doc["course_id"];
//       var link = doc["link"];
//       var path = doc["path"];
//       topicname = doc["filename"];
//       url = path == ''
//           ? ApiService.websiteUrl + "" + path + '/' + courseId + '/' + link
//           : link;
//       print(url);
//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           topicname,
//           style:
//               const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 15),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: url == ''
//           ? const Text('Loading...')
//           : SfPdfViewer.network(
//               url,
//               key: _pdfViewerKey,
//             ),
//     );
//   }
// }
