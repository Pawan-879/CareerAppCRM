import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:flutter/material.dart';
import '../../../models/shorts_video_model.dart';
import '../shorts/widgets/shorts_content_widget.dart';

class SwipeShortsScreen extends StatefulWidget {
  final List<ShortItem> shortsList;
  final int index;
  final String userId;
  final String userName;
  const SwipeShortsScreen({
    Key? key,
    required this.shortsList,
    required this.userId,
    required this.userName,
    required this.index,
  }) : super(key: key);

  @override
  State<SwipeShortsScreen> createState() => _SwipeShortsScreenState();
}

class _SwipeShortsScreenState extends State<SwipeShortsScreen> {
  List<ShortItem> shortsList = [];
  String message = '';
  @override
  void initState() {
    shortsList = widget.shortsList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: SafeArea(
        child: Stack(
          children: [
            Swiper(
              itemCount: shortsList.length,
              index: widget.index,
              itemBuilder: (context, int index) {
                return ContentWidget(
                  src: shortsList[index],
                  userId: widget.userId,
                  userName: widget.userName,
                );
              },
              scrollDirection: Axis.vertical,
              loop: true,
              controller: SwiperController(),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
