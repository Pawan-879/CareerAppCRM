import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:careerapp/screens/PhotoGalleryDetailPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../models/feed_model.dart';
import '../../../services/api_services.dart';
import 'expandable_text.dart';
import 'feed_report_sheets.dart';
import 'video_player_widget.dart';

class FeedWidget extends StatefulWidget {
  final FeedItem feed;
  final String usedId;
  final String userName;
  final Function() notifyParent;

  const FeedWidget({
    Key? key,
    required this.feed,
    required this.notifyParent,
    required this.usedId,
    required this.userName,
  }) : super(key: key);

  @override
  State<FeedWidget> createState() => _FeedWidgetState();
}

class _FeedWidgetState extends State<FeedWidget> {
  late FeedItem feed;

  final TextEditingController commentCntrlr = TextEditingController();
  final PageController _postImagePageController = PageController();

  Timer? _postImageAutoSlideTimer;

  final Set<int> _preloadedImageIndexes = <int>{};

  int _currentPostImageIndex = 0;
  int likeCount = 0;

  bool _isPostImageAutoSliding = true;
  bool _isLikeRequestInProgress = false;
  bool isLiked = false;
  bool isBookmarked = false;
  bool showCommentSection = false;

  @override
  void initState() {
    super.initState();

    feed = widget.feed;
    likeCount = int.tryParse(feed.likesCount?.totalLikes?.toString() ?? '0') ?? 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preparePostImages();
    });
  }

  @override
  void dispose() {
    _postImageAutoSlideTimer?.cancel();
    _postImagePageController.dispose();
    commentCntrlr.dispose();
    super.dispose();
  }

  List<String> get _postImages => feed.image ?? <String>[];

  Future<void> _preparePostImages() async {
    final List<String> images = _postImages;

    if (!mounted || feed.mediaType != 'image' || images.isEmpty) {
      return;
    }

    await _precachePostImage(0);

    if (images.length > 1) {
      _precachePostImage(1);
    }

    if (mounted) {
      _startPostImageAutoSlide();
    }
  }

  Future<void> _precachePostImage(int index) async {
    final List<String> images = _postImages;

    if (!mounted ||
        index < 0 ||
        index >= images.length ||
        _preloadedImageIndexes.contains(index)) {
      return;
    }

    final String imageUrl = images[index].trim();

    if (imageUrl.isEmpty) {
      return;
    }

    _preloadedImageIndexes.add(index);

    try {
      await precacheImage(
        CachedNetworkImageProvider(imageUrl),
        context,
      );
    } catch (_) {
      // Image error widget will be shown in the UI.
    }
  }

  void _startPostImageAutoSlide() {
    _postImageAutoSlideTimer?.cancel();

    final List<String> images = _postImages;

    if (feed.mediaType != 'image' || images.length < 2) {
      return;
    }

    _isPostImageAutoSliding = true;
    _scheduleNextPostImageSlide();
  }

  void _scheduleNextPostImageSlide() {
    _postImageAutoSlideTimer?.cancel();

    if (!mounted || !_isPostImageAutoSliding) {
      return;
    }

    final List<String> images = _postImages;

    if (images.length < 2) {
      return;
    }

    _postImageAutoSlideTimer = Timer(
      const Duration(seconds: 4),
      () async {
        if (!mounted || !_isPostImageAutoSliding) {
          return;
        }

        if (!_postImagePageController.hasClients) {
          _scheduleNextPostImageSlide();
          return;
        }

        final int nextIndex = (_currentPostImageIndex + 1) % images.length;

        _precachePostImage(nextIndex);
        _precachePostImage((nextIndex + 1) % images.length);

        try {
          await _postImagePageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
          );
        } catch (_) {
          // Widget can be removed from the feed during the animation.
        }

        if (mounted && _isPostImageAutoSliding) {
          _scheduleNextPostImageSlide();
        }
      },
    );
  }

  void _stopPostImageAutoSlide() {
    if (!_isPostImageAutoSliding) {
      return;
    }

    _postImageAutoSlideTimer?.cancel();

    if (mounted) {
      setState(() {
        _isPostImageAutoSliding = false;
      });
    }
  }

  Future<void> _sharePost() async {
    final String postTitle = _safeText(feed.title, fallback: 'Check this out!');
    final String postBody = _safeText(feed.body);
    final String postUrl = _postImages.isNotEmpty ? _postImages.first : '';

    final String shareContent = <String>[
      postTitle,
      if (postBody.isNotEmpty) postBody,
      if (postUrl.isNotEmpty) postUrl,
    ].join('\n\n');

    try {
      await Share.share(shareContent);
    } catch (_) {
      Fluttertoast.showToast(msg: 'Unable to share this post.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(2.8.w, 0.5.h, 2.8.w, 1.8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            _buildMediaSection(),
            _buildActionButtons(),
            _buildPostMetrics(),
            _buildCaptionSection(),
            _buildCommentsPreview(),
            _buildPostTime(),
            _buildAddCommentSection(),
            _buildInterestButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final String categoryName = _safeText(
      feed.postCategoryName,
      fallback: 'School Update',
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(3.8.w, 1.7.h, 2.2.w, 1.4.h),
      child: Row(
        children: [
          Container(
            width: 10.5.w,
            height: 10.5.w,
            padding: const EdgeInsets.all(2.2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xFF833AB4),
                  Color(0xFFFD1D1D),
                  Color(0xFFFCAF45),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/profileimg.png'),
              ),
            ),
          ),
          SizedBox(width: 2.8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Career Defence School',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF191A20),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.8.sp,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 17,
                      height: 17,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF258AF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 11,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.3.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10.6.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '•',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Text(
                      'School Life',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10.4.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'More options',
            splashRadius: 21,
            onPressed: _feedOtionsBottomSheetMenu,
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFF202124),
              size: 27,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    final List<String> images = _postImages;

    if (feed.mediaType != 'image') {
      return CustomVideoPlayer(
        play: false,
        feedItem: feed,
        userId: widget.usedId,
        userName: widget.userName,
      );
    }

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    if (images.length == 1) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _handleDoubleTapLike,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoGalleryDetailPage(
                imagePaths: images,
                currentIndex: 0,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            _buildPostImage(images.first, contain: true),
            Positioned(
              right: 12,
              bottom: 12,
              child: _buildOpenMediaLabel(),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: _mediaHeight(context),
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _stopPostImageAutoSlide();
              }
              return false;
            },
            child: PageView.builder(
              controller: _postImagePageController,
              itemCount: images.length,
              allowImplicitScrolling: true,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (int index) {
                if (!mounted) {
                  return;
                }

                setState(() {
                  _currentPostImageIndex = index;
                });

                _precachePostImage(index - 1);
                _precachePostImage(index + 1);
                _precachePostImage(index + 2);
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _stopPostImageAutoSlide();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoGalleryDetailPage(
                          imagePaths: images,
                          currentIndex: _currentPostImageIndex,
                        ),
                      ),
                    );
                  },
                  onDoubleTap: _handleDoubleTapLike,
                  child: _buildPostImage(images[index]),
                );
              },
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _buildMediaBadge(
              icon: Icons.photo_library_outlined,
              text: 'Campus Moments',
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _buildMediaBadge(
              icon: Icons.layers_rounded,
              text: '${_currentPostImageIndex + 1} / ${images.length}',
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 78,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black.withOpacity(0.42),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child: IgnorePointer(
              child: _buildImagePageIndicator(images.length),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 10,
            child: _buildOpenMediaLabel(),
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(String imageUrl, {bool contain = false}) {
    final int cacheWidth = _mediaCacheWidth(context);
    final int cacheHeight = _mediaCacheHeight(context);
    final double mediaHeight = _mediaHeight(context);

    return SizedBox(
      height: mediaHeight,
      width: double.infinity,
      child: ColoredBox(
        color: contain ? Colors.black : const Color(0xFFF0F2F5),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: contain ? BoxFit.contain : BoxFit.cover,
          width: double.infinity,
          height: mediaHeight,
          memCacheWidth: cacheWidth,
          memCacheHeight: cacheHeight,
          maxWidthDiskCache: cacheWidth,
          maxHeightDiskCache: cacheHeight,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          useOldImageOnUrlChange: true,
          filterQuality: FilterQuality.medium,
          progressIndicatorBuilder: (context, url, progress) {
            return _buildImageLoadingState(progress.progress);
          },
          errorWidget: (context, url, error) {
            return Container(
              color: const Color(0xFFF0F2F5),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey.shade500,
                    size: 42,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Image not available',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageLoadingState(double? progress) {
    final double progressValue = (progress ?? 0).clamp(0.0, 1.0).toDouble();

    return Container(
      color: const Color(0xFFF0F2F5),
      alignment: Alignment.center,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: progressValue > 0 ? progressValue : null,
              color: const Color(0xFFEF476F),
              strokeWidth: 3,
            ),
            const SizedBox(height: 10),
            Text(
              'Loading photo',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.58),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenMediaLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fullscreen_rounded,
            size: 16,
            color: Color(0xFF1E88E5),
          ),
          SizedBox(width: 4),
          Text(
            'View',
            style: TextStyle(
              color: Color(0xFF1E88E5),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePageIndicator(int imageCount) {
    if (imageCount > 8) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.42),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Swipe for more photos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(imageCount, (int index) {
        final bool selected = index == _currentPostImageIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 7,
          width: selected ? 18 : 7,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(3.3.w, 1.25.h, 3.3.w, 0.5.h),
      child: Row(
        children: [
          _buildSocialActionButton(
            icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            iconColor: isLiked ? const Color(0xFFEF476F) : const Color(0xFF202124),
            onTap: _handlePostLike,
          ),
          SizedBox(width: 2.2.w),
          _buildSocialActionButton(
            icon: Icons.mode_comment_outlined,
            iconColor: const Color(0xFF202124),
            onTap: () {
              setState(() {
                showCommentSection = !showCommentSection;
              });
            },
          ),
          SizedBox(width: 2.2.w),
          _buildSocialActionButton(
            icon: FontAwesomeIcons.paperPlane,
            iconColor: const Color(0xFF202124),
            iconSize: 21,
            onTap: _sharePost,
          ),
          const Spacer(),
          _buildSocialActionButton(
            icon: isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            iconColor: isBookmarked
                ? const Color(0xFF1E88E5)
                : const Color(0xFF202124),
            onTap: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });

              Fluttertoast.showToast(
                msg: isBookmarked ? 'Post saved' : 'Post removed',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialActionButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    double iconSize = 27,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 25,
        containedInkWell: true,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPostMetrics() {
    final int commentsCount = feed.comments?.length ?? 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          if (likeCount > 0)
            Text(
              '$likeCount ${likeCount == 1 ? 'like' : 'likes'}',
              style: TextStyle(
                color: const Color(0xFF1D1D1F),
                fontWeight: FontWeight.w800,
                fontSize: 11.4.sp,
              ),
            )
          else
            Text(
              'Be the first to like this',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 10.7.sp,
              ),
            ),
          const Spacer(),
          if (commentsCount > 0)
            Text(
              '$commentsCount ${commentsCount == 1 ? 'comment' : 'comments'}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10.8.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptionSection() {
    final String title = _safeText(feed.title);
    final String body = _safeText(feed.body);

    if (title.isEmpty && body.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.1.h, 4.w, 0.35.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: body.isEmpty ? 0 : 0.55.h),
              child: Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF16171B),
                  fontSize: 13.2.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ),
          if (body.isNotEmpty)
            ReadMoreText(
              body,
              trimLines: 2,
              colorClickableText: const Color(0xFF1677E8),
              trimCollapsedText: ' Read more',
              trimExpandedText: ' Show less',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: const Color(0xFF33343A),
                fontSize: 11.8.sp,
                height: 1.42,
              ),
              moreStyle: TextStyle(
                color: const Color(0xFF1677E8),
                fontSize: 11.8.sp,
                fontWeight: FontWeight.w800,
              ),
              lessStyle: TextStyle(
                color: const Color(0xFF1677E8),
                fontSize: 11.8.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentsPreview() {
    final List<FeedComment> comments = feed.comments ?? <FeedComment>[];

    if (comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(4.w, 0.6.h, 4.w, 0),
        child: Text(
          'No comments yet',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10.9.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (comments.length > 2 && !showCommentSection)
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0.8.h, 4.w, 0.4.h),
            child: InkWell(
              onTap: () {
                setState(() {
                  showCommentSection = true;
                });
              },
              child: Text(
                'View all ${comments.length} comments',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10.9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ...comments
            .take(showCommentSection ? comments.length : 2)
            .map(_buildCommentItem)
            .toList(),
      ],
    );
  }

  Widget _buildCommentItem(FeedComment comment) {
    final String name = _safeText(comment.userName, fallback: 'User');
    final String commentText = _safeText(comment.comment);

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0.8.h, 4.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage('assets/profileimg.png'),
          ),
          SizedBox(width: 2.5.w),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(13),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: name,
                      style: TextStyle(
                        color: const Color(0xFF202124),
                        fontSize: 11.1.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: commentText.isEmpty ? '' : '  $commentText',
                      style: TextStyle(
                        color: const Color(0xFF3D4148),
                        fontSize: 11.1.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTime() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 0.45.h),
      child: Text(
        _getPostTimeText().toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 9.7.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildAddCommentSection() {
    final bool canPost = commentCntrlr.text.trim().isNotEmpty;

    return Container(
      margin: EdgeInsets.fromLTRB(3.3.w, 0.8.h, 3.3.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.45.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundImage: AssetImage('assets/profileimg.png'),
          ),
          SizedBox(width: 2.3.w),
          Expanded(
            child: TextField(
              controller: commentCntrlr,
              onChanged: (_) {
                if (mounted) {
                  setState(() {});
                }
              },
              style: TextStyle(
                color: const Color(0xFF2E3036),
                fontSize: 11.5.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11.3.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 1.1.h),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: canPost
                ? () {
                    _handleCommentPost(commentCntrlr.text);
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              child: Text(
                'Post',
                style: TextStyle(
                  color: canPost
                      ? const Color(0xFF1677E8)
                      : Colors.blue.shade200,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(3.3.w, 1.2.h, 3.3.w, 1.7.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Fluttertoast.showToast(msg: 'Marked as Not Interested');
              },
              icon: const Icon(
                Icons.close_rounded,
                size: 17,
                color: Color(0xFFE95454),
              ),
              label: const Text(
                'Not Interested',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFFE95454),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE95454),
                side: const BorderSide(
                  color: Color(0xFFFFCACA),
                ),
                backgroundColor: const Color(0xFFFFF7F7),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.6.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Fluttertoast.showToast(msg: 'Marked as Interested');
              },
              icon: const Icon(
                Icons.check_rounded,
                size: 17,
                color: Color(0xFF25A46C),
              ),
              label: const Text(
                'Interested',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF25A46C),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF25A46C),
                side: const BorderSide(
                  color: Color(0xFFBCE8D0),
                ),
                backgroundColor: const Color(0xFFF4FCF8),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCommentPost(String comment) async {
    final String cleanComment = comment.trim();

    if (widget.usedId.isEmpty) {
      Fluttertoast.showToast(msg: 'Log in to comment');
      return;
    }

    if (cleanComment.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter comment.');
      return;
    }

    final String requestData = json.encode(<String, dynamic>{
      'user_id': widget.usedId,
      'post_id': feed.id,
      'comment': cleanComment,
    });

    try {
      final dynamic response = await ApiService.postMethod4(
        'Api/addComment',
        requestData,
      );

      if (response['status']?.toString() == '1') {
        Fluttertoast.showToast(msg: 'Comment posted.');

        FocusScope.of(context).unfocus();

        if (!mounted) {
          return;
        }

        setState(() {
          feed.comments ??= <FeedComment>[];
          feed.comments!.add(
            FeedComment(
              comment: cleanComment,
              userName: widget.userName,
            ),
          );
          showCommentSection = true;
        });

        commentCntrlr.clear();
      } else {
        Fluttertoast.showToast(msg: 'Unable to post comment.');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      Fluttertoast.showToast(msg: 'Unable to post comment.');
    }
  }

  Future<void> _handlePostLike() async {
    if (widget.usedId.isEmpty) {
      Fluttertoast.showToast(msg: 'Log in to like this post.');
      return;
    }

    if (_isLikeRequestInProgress) {
      return;
    }

    final bool previousLikedState = isLiked;
    final int previousLikeCount = likeCount;
    final bool optimisticLikeState = !previousLikedState;

    setState(() {
      _isLikeRequestInProgress = true;
      isLiked = optimisticLikeState;
      likeCount = previousLikeCount + (optimisticLikeState ? 1 : -1);

      if (likeCount < 0) {
        likeCount = 0;
      }
    });

    final String requestData = json.encode(<String, dynamic>{
      'user_id': widget.usedId,
      'post_id': feed.id,
    });

    try {
      final dynamic response = await ApiService.postMethod4(
        'Api/addLike',
        requestData,
      );

      final String status = response['status']?.toString() ?? '';

      if (!mounted) {
        return;
      }

      if (status == '1' || status == '2') {
        final bool serverLikedState = status == '1';

        setState(() {
          isLiked = serverLikedState;
          likeCount = previousLikeCount +
              (serverLikedState ? 1 : 0) -
              (previousLikedState ? 1 : 0);

          if (likeCount < 0) {
            likeCount = 0;
          }
        });

        if (serverLikedState) {
          Fluttertoast.showToast(msg: 'Liked');
        }
      } else {
        setState(() {
          isLiked = previousLikedState;
          likeCount = previousLikeCount;
        });
        Fluttertoast.showToast(msg: 'Unable to update like.');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }

      if (mounted) {
        setState(() {
          isLiked = previousLikedState;
          likeCount = previousLikeCount;
        });
      }

      Fluttertoast.showToast(msg: 'Unable to update like.');
    } finally {
      if (mounted) {
        setState(() {
          _isLikeRequestInProgress = false;
        });
      }
    }
  }

  void _handleDoubleTapLike() {
    if (!isLiked) {
      _handlePostLike();
    }
  }

  void _feedOtionsBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return const FeedReportOptions();
      },
    );
  }

  String _safeText(dynamic value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }

    final String text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  double _mediaHeight(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double desiredHeight = size.width * 1.12;
    final double maxHeight = size.height * 0.60;
    final double safeMaxHeight = maxHeight < 300 ? 300 : maxHeight;

    return desiredHeight.clamp(300.0, safeMaxHeight).toDouble();
  }

  int _mediaCacheWidth(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return (size.width * pixelRatio).clamp(720.0, 1120.0).round();
  }

  int _mediaCacheHeight(BuildContext context) {
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    return (_mediaHeight(context) * pixelRatio).clamp(900.0, 1600.0).round();
  }

  String _getPostTimeText() {
    final String scheduledAt = _safeText(feed.scheduled_at);
    final String createdAt = _safeText(feed.createdAt);

    final String selectedDate = scheduledAt == '0000-00-00 00:00:00' ||
            scheduledAt.isEmpty
        ? createdAt
        : scheduledAt;

    final DateTime? dateTime = DateTime.tryParse(selectedDate);

    if (dateTime == null) {
      return 'Recently';
    }

    return timeAgoCustom(dateTime);
  }

  String timeAgoCustom(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inDays > 365) {
      final int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }

    if (difference.inDays > 30) {
      final int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }

    if (difference.inDays > 7) {
      final int weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }

    if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    }

    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }

    return 'Just now';
  }
}
