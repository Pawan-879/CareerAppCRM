// import 'package:syncfusion_flutter_pdfviewer/PDFViewer.dart';

// class PDFViewer2 extends StatefulWidget {
//   static const String routeName = 'pdf_viewer2';

//   const PDFViewer2({Key? key}) : super(key: key);

//   @override
//   _PDFViewerState createState() => _PDFViewerState();
// }

// class _PDFViewerState extends State<PDFViewer2> {
//   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
//   String url = "";
//   String topicname = "PDF Viewer";

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () {
//       dynamic doc = ModalRoute.of(context)!.settings.arguments;

//       var link = doc["link"];

//       topicname = doc["filename"];
//       url = link;
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
