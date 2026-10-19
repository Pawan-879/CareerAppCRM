import 'package:flutter/material.dart';

class FeedReportOptions extends StatelessWidget {
  const FeedReportOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 6,
      color: const Color(0xFF737373),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                trailing: const Icon(Icons.report_outlined),
                title: const Text('Report post'),
                onTap: () {},
              ),
              ListTile(
                trailing: const Icon(Icons.hide_source_outlined),
                title: const Text('Hide this content'),
                onTap: () {},
              ),
            ],
          )),
    );
  }
}
