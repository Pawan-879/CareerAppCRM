import 'package:flutter/material.dart';
import 'package:careerapp/screens/freeplayer.dart';
import 'package:careerapp/screens/freeplayer2.dart';
import 'package:careerapp/screens/freeplayer3.dart';
import 'dart:io' show Platform;
import 'package:fluttertoast/fluttertoast.dart';

class VideoTile extends StatelessWidget {
  final String? number;
  final String? title;
  final bool? isDone;
  final String? sectionId;
  final String? playerType;
  final int? flag;
  const VideoTile({
    Key? key,
    this.number,
    this.title,
    this.sectionId,
    this.playerType,
    this.flag,
    this.isDone = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        color: Colors.blue[50],
        child: ListTile(
          onTap: () {
            dynamic data88 = {'section_id': sectionId, 'type': flag};

            if (int.parse(number!) < 4 && flag == 0) {
              if (int.parse(playerType!) == 0) {
                if (Platform.isAndroid) {
                  Navigator.of(context)
                      .pushNamed(FreePlayerScreen.routeName, arguments: data88);
                } else if (Platform.isIOS) {
                  Navigator.of(context).pushNamed(FreePlayerScreen3.routeName,
                      arguments: data88);
                }
              } else {
                Navigator.of(context)
                    .pushNamed(FreePlayerScreen2.routeName, arguments: data88);
              }
            } else if (flag == 0) {
              Fluttertoast.showToast(
                  msg: "Please buy this course", timeInSecForIosWeb: 10);
            }

            if (flag == 1) {
              if (int.parse(playerType!) == 0) {
                if (Platform.isAndroid) {
                  Navigator.of(context)
                      .pushNamed(FreePlayerScreen.routeName, arguments: data88);
                } else if (Platform.isIOS) {
                  Navigator.of(context).pushNamed(FreePlayerScreen3.routeName,
                      arguments: data88);
                }
              } else {
                Navigator.of(context)
                    .pushNamed(FreePlayerScreen2.routeName, arguments: data88);
              }
            }
          },
          leading: Text(number!,
              style: TextStyle(
                fontSize: 32,
                color: const Color(0xFF0D1333).withOpacity(0.15),
                fontWeight: FontWeight.bold,
              )),
          title: Text(
            title!,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF0D1333),
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: int.parse(number!) > 3 && flag == 0
              ? Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.blue),
                  child: const Icon(Icons.do_not_disturb, color: Colors.white),
                )
              : Container(
                  height: 30,
                  width: 30,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.blue),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
