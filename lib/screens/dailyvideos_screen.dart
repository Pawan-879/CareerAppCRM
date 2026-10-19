// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';

// class DailyVideos extends StatefulWidget {
//   const DailyVideos({Key? key}) : super(key: key);
//   static const routeName = '/daily_videos';

//   @override
//   State<DailyVideos> createState() => _DailyVideosState();
// }



// class _DailyVideosState extends State<DailyVideos> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final ScrollController _scrollController = ScrollController();
//   bool _isScrolled = false;

//  final List<Map<String, dynamic>> videos = const [
//   {
//     "title": "Top 5 Benefits of Hostel Life",
//     "url": "https://youtu.be/-rsQnyq_yOY?feature=shared",
//     "id": "-rsQnyq_yOY",
//     "duration": "12:45",
//     "views": "245K",
//     "date": "2 weeks ago",
//     "channel": "Student Diaries",
//     "category": "Hostel"
//   },
//   {
//     "title": "Why Everyone Should Experience Hostel Living",
//     "url": "https://www.youtube.com/watch?v=dj56SeePaUA",
//     "id": "dj56SeePaUA",
//     "duration": "8:32",
//     "views": "189K",
//     "date": "3 days ago",
//     "channel": "Campus Life",
//     "category": "Hostel"
//   },
//   {
//     "title": "Hostel Life: A Journey of Independence",
//     "url": "https://www.youtube.com/watch?v=U1X61QbotLE&t=10s",
//     "id": "U1X61QbotLE",
//     "duration": "15:20",
//     "views": "321K",
//     "date": "1 month ago",
//     "channel": "Youth Talks",
//     "category": "Hostel"
//   },
//   {
//     "title": "Making Lifelong Friends in Hostels",
//     "url": "https://www.youtube.com/watch?v=WCOiUAJvfzU",
//     "id": "WCOiUAJvfzU",
//     "duration": "10:15",
//     "views": "178K",
//     "date": "5 days ago",
//     "channel": "Roommate Stories",
//     "category": "Hostel"
//   },
//   {
//     "title": "Hostel Hacks: Making the Most of Shared Spaces",
//     "url": "https://www.youtube.com/watch?v=hFmkTLHjDtg",
//     "id": "hFmkTLHjDtg",
//     "duration": "22:48",
//     "views": "512K",
//     "date": "2 months ago",
//     "channel": "Student Smart",
//     "category": "Hostel"
//   },
//   {
//     "title": "What I Learned from 3 Years in a Hostel",
//     "url": "https://www.youtube.com/watch?v=WCOiUAJvfzU&t=26s",
//     "id": "WCOiUAJvfzU",
//     "duration": "18:30",
//     "views": "203K",
//     "date": "3 weeks ago",
//     "channel": "Life Lessons",
//     "category": "Hostel"
//   },
// ];


//  final List<String> _categories = ['All'];


//   @override
//   void initState() {
//     super.initState();
//     // _tabController = TabController(length: _categories.length, vsync: this);
//     _tabController = TabController(length: _categories.length, vsync: this);

    
//     _scrollController.addListener(() {
//       setState(() {
//         _isScrolled = _scrollController.offset > 0;
//       });
//     });
    
//     // Set status bar to transparent
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.light,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: NestedScrollView(
//         controller: _scrollController,
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverAppBar(
//               expandedHeight: 100.0,
//               floating: false,
//               pinned: true,
//               elevation: 0,
//               backgroundColor: const Color(0xFF1E3A8A),
//               flexibleSpace: FlexibleSpaceBar(
//                 title: AnimatedOpacity(
//                   opacity: _isScrolled ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 300),
//                   child: const Text(
//                     'Daily Videos',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 background: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     // Gradient background
//                     Container(
//                       decoration: const BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Color(0xFF1E3A8A),
//                             Color(0xFF2563EB),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Pattern overlay
//                     Opacity(
//                       opacity: 0.1,
//                       child: CustomPaint(
//                         painter: PatternPainter(),
//                       ),
//                     ),
//                     // Content
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           const Text(
//                             'Daily Videos',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Discover the best content for you',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.8),
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // actions: [
//               //   IconButton(
//               //     icon: const Icon(Icons.search, color: Colors.white),
//               //     onPressed: () {},
//               //   ),
//               //   IconButton(
//               //     icon: const Icon(Icons.filter_list, color: Colors.white),
//               //     onPressed: () {},
//               //   ),
//               // ],
//             ),
//             // SliverPersistentHeader(
//             //   delegate: _SliverAppBarDelegate(
//             //     TabBar(
//             //       controller: _tabController,
//             //       isScrollable: true,
//             //       labelColor: const Color(0xFF2563EB),
//             //       unselectedLabelColor: Colors.grey[600],
//             //       labelStyle: const TextStyle(fontWeight: FontWeight.bold),
//             //       indicator: BoxDecoration(
//             //         borderRadius: BorderRadius.circular(50),
//             //         color: Colors.white,
//             //         boxShadow: [
//             //           BoxShadow(
//             //             color: Colors.black.withOpacity(0.1),
//             //             blurRadius: 4,
//             //             offset: const Offset(0, 2),
//             //           ),
//             //         ],
//             //       ),
//             //       tabs: _categories.map((category) => Tab(text: category)).toList(),
//             //     ),
//             //     const Color(0xFFF3F4F6),
//             //   ),
//             //   pinned: true,
//             // ),
//           ];
//         },
//         body: TabBarView(
//           controller: _tabController,
//           children: _categories.map((category) {
//             final filteredVideos = category == 'All'
//                 ? videos
//                 : videos.where((video) => video['category'] == category).toList();
            
//             return filteredVideos.isEmpty
//                 ? const Center(child: Text('No videos in this category'))
//                 : _buildVideoList(filteredVideos);
//           }).toList(),
//         ),
//       ),
//       floatingActionButton: AnimatedOpacity(
//         opacity: _isScrolled ? 1.0 : 0.0,
//         duration: const Duration(milliseconds: 300),
//         child: FloatingActionButton(
//           backgroundColor: const Color(0xFF2563EB),
//           child: const Icon(Icons.arrow_upward),
//           onPressed: () {
//             _scrollController.animateTo(
//               0,
//               duration: const Duration(milliseconds: 500),
//               curve: Curves.easeInOut,
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildVideoList(List<Map<String, dynamic>> videoList) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: videoList.length,
//       itemBuilder: (context, index) {
//          final video = videoList[index]; 
// //        AspectRatio(
// //   aspectRatio: 16 / 9,
// //   child: _buildThumbnail(video['id']),
// // ),



//         return Hero(
//           tag: 'video-${video['id']}',
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: () async {
//                     final uri = Uri.parse(video['url']!);
//                     if (await canLaunchUrl(uri)) {
//                       await launchUrl(uri, mode: LaunchMode.externalApplication);
//                     }
//                   },
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Thumbnail with overlay
//                       Stack(
//                         children: [
//                           // Thumbnail
//                           AspectRatio(
//                             aspectRatio: 16 / 9,
//                             // child: _buildThumbnail(thumbnailUrl),
//                             child: _buildThumbnail(video['id']),

//                           ),
//                           // Duration badge
//                           Positioned(
//                             bottom: 12,
//                             right: 12,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.7),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 video['duration'],
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // Play button overlay
//                           Positioned.fill(
//                             child: Center(
//                               child: Container(
//                                 height: 50,
//                                 width: 50,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.9),
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.2),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: const Icon(
//                                   Icons.play_arrow_rounded,
//                                   color: Color(0xFFEF4444),
//                                   size: 30,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // Category tag
//                           Positioned(
//                             top: 12,
//                             left: 12,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                               decoration: BoxDecoration(
//                                 color: _getCategoryColor(video['category']),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 video['category'],
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       // Video info
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               video['title'],
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937),
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 14,
//                                   backgroundColor: Colors.grey[200],
//                                   child: Icon(
//                                     FontAwesomeIcons.user,
//                                     size: 14,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   video['channel'],
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Icon(
//                                   Icons.visibility_outlined,
//                                   size: 16,
//                                   color: Colors.grey[600],
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   video['views'],
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   video['date'],
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                                 Row(
//                                   children: [
//                                     _buildActionButton(
//                                       icon: Icons.favorite_border,
//                                       color: Colors.grey[700]!,
//                                     ),
//                                     _buildActionButton(
//                                       icon: Icons.bookmark_border,
//                                       color: Colors.grey[700]!,
//                                     ),
//                                     _buildActionButton(
//                                       icon: Icons.share_outlined,
//                                       color: Colors.grey[700]!,
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//  Widget _buildThumbnail(String videoId) {
//   return YouTubeThumbnailLoader(videoId: videoId);
// }


//   Widget _buildActionButton({required IconData icon, required Color color}) {
//     return Container(
//       margin: const EdgeInsets.only(left: 8),
//       width: 36,
//       height: 36,
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         shape: BoxShape.circle,
//       ),
//       child: IconButton(
//         icon: Icon(icon, size: 18),
//         color: color,
//         onPressed: () {},
//       ),
//     );
//   }

//   Color _getCategoryColor(String category) {
//     switch (category) {
//       case 'Tutorial':
//         return const Color(0xFF3B82F6); // Blue
//       case 'Design':
//         return const Color(0xFF8B5CF6); // Purple
//       case 'Animation':
//         return const Color(0xFFEC4899); // Pink
//       case 'Beginner':
//         return const Color(0xFF10B981); // Green
//       case 'Advanced':
//         return const Color(0xFFF59E0B); // Amber
//       default:
//         return const Color(0xFF6B7280); // Gray
//     }
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar _tabBar;
//   final Color _backgroundColor;

//   _SliverAppBarDelegate(this._tabBar, this._backgroundColor);

//   @override
//   double get minExtent => _tabBar.preferredSize.height + 16;
  
//   @override
//   double get maxExtent => _tabBar.preferredSize.height + 16;

//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: _backgroundColor,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: _tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }

// class PatternPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.1)
//       ..strokeWidth = 1.0
//       ..style = PaintingStyle.stroke;

//     const spacing = 20.0;
    
//     for (double i = 0; i < size.width + size.height; i += spacing) {
//       canvas.drawLine(
//         Offset(0, i),
//         Offset(i, 0),
//         paint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }

// class ShimmerLoadingImage extends StatefulWidget {
//   final String imageUrl;
//   final VoidCallback? onError;

//    const ShimmerLoadingImage({
//     Key? key,
//     required this.imageUrl,
//     this.onError,
//   }) : super(key: key);

//   @override
//   State<ShimmerLoadingImage> createState() => _ShimmerLoadingImageState();
// }

// class _ShimmerLoadingImageState extends State<ShimmerLoadingImage> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   bool _isLoading = true;
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat();
    
//     _animation = Tween<double>(begin: -2, end: 2).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Shimmer effect
//         if (_isLoading)
//           AnimatedBuilder(
//             animation: _animation,
//             builder: (context, child) {
//               return Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment(_animation.value, 0),
//                     end: Alignment(_animation.value + 1, 0),
//                     colors: [
//                       Colors.grey[300]!,
//                       Colors.grey[100]!,
//                       Colors.grey[300]!,
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
        
//         // Image
//         Image.network(
//           widget.imageUrl,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             _hasError = true;
//             _isLoading = false;
//             return Container(
//               color: Colors.grey[300],
//               child: const Center(
//                 child: Icon(
//                   Icons.error_outline,
//                   color: Colors.grey,
//                   size: 40,
//                 ),
//               ),
//             );
//           },
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) {
//               // Loading is done
//               Future.delayed(const Duration(milliseconds: 300), () {
//                 if (mounted) {
//                   setState(() {
//                     _isLoading = false;
//                   });
//                 }
//               });
//               return child;
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ],
//     );
//   }
// }
// class YouTubeThumbnailLoader extends StatefulWidget {
//   final String videoId;

//   const YouTubeThumbnailLoader({Key? key, required this.videoId}) : super(key: key);

//   @override
//   State<YouTubeThumbnailLoader> createState() => _YouTubeThumbnailLoaderState();
// }

// class _YouTubeThumbnailLoaderState extends State<YouTubeThumbnailLoader> {
//   late String _thumbnailUrl;
//   bool _triedFallback = false;

//   @override
//   void initState() {
//     super.initState();
//     _thumbnailUrl = 'https://img.youtube.com/vi/${widget.videoId}/maxresdefault.jpg';
//   }

//   void _fallbackToLowerResolution() {
//     if (!_triedFallback) {
//       setState(() {
//         _thumbnailUrl = 'https://img.youtube.com/vi/${widget.videoId}/hqdefault.jpg';
//         _triedFallback = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ShimmerLoadingImage(
//       imageUrl: _thumbnailUrl,
//       onError: _fallbackToLowerResolution,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:careerapp/screens/dailyvideos_player.dart';
import 'package:careerapp/screens/login.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyVideos extends StatefulWidget {
  const DailyVideos({Key? key}) : super(key: key);
  static const routeName = '/daily_videos';

  @override
  _DailyVideosState createState() => _DailyVideosState();
}

class _DailyVideosState extends State<DailyVideos>
    with TickerProviderStateMixin {
  var section_id = "";
  var data4 = [], data4_copy = [], data5 = [], data5_copy = [];
  var userData, user_id = "";
  var categories = [];
  final List _selecteCategorys = [];
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    
    getUserData();
    getCategories();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      userData = json.decode(prefs.getString('userData')!);
      user_id = userData["user_id"];
      await getData2(user_id);
      await getData3(user_id);
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    } else {
      await getData();
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    }
  }

  getData() async {
    var res = await ApiService.getMethod("/getDailyVideos");
    data4 = jsonDecode(res.body);
    data4_copy = jsonDecode(res.body);
    setState(() {});
  }

  myfilter() {
    data4_copy = data4.where((element) => _selecteCategorys.contains(element["category_id"])).toList();
    data5_copy = data5.where((element) => _selecteCategorys.contains(element["category_id"])).toList();
    setState(() {});
  }

  getCategories() async {
    var res = await ApiService.getMethod("/getAppCategories");
    categories = json.decode(res.body)["detail"];
    setState(() {});
  }

  getData2(userId2) async {
    var res = await ApiService.getMethod("/getDailyVideos?user_id=$userId2&type=unwatched");
    data4 = jsonDecode(res.body);
    data4_copy = jsonDecode(res.body);
    setState(() {});
  }

  getData3(userId2) async {
    var res = await ApiService.getMethod("/getDailyVideos?user_id=$userId2&type=watched");
    data5 = jsonDecode(res.body);
    data5_copy = jsonDecode(res.body);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8FAFF),
                Color(0xFFE8F4FD),
              ],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF667EEA),
                      Color(0xFF764BA2),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.video,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            "Daily Videos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // const Icon(
                              //   FontAwesomeIcons.bell,
                              //   color: Colors.white,
                              //   size: 20,
                              // ),
                              if (data4_copy.isNotEmpty)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                    child: Text(
                                      '${data4_copy.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: const Color(0xFF667EEA),
                        unselectedLabelColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: 'Unwatched'),
                          Tab(text: 'Watched'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: TabBarView(
                            children: [
                              _buildVideoList(data4_copy, 'unwatched'),
                              user_id.isEmpty
                                  ? _buildLoginPrompt()
                                  : _buildVideoList(data5_copy, 'watched'),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: ScaleTransition(
          scale: _fadeAnimation,
          child: FloatingActionButton.extended(
            onPressed: popup,
            label: const Text(
              'Filter',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            icon: const Icon(FontAwesomeIcons.sliders, size: 16),
            backgroundColor: const Color(0xFF667EEA),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading amazing videos...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.lock,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Login Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please login to view your watched videos and get personalized recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                "Login Now",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList(List data, String type) {
    if (data.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: data.length,
      itemBuilder: (context, index) {
        var video = data[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutCubic,
          child: _courseCard(
            video["id"],
            video["video_link"],
            video["quote_name"],
            video["quote_image"],
            video,
            type,
            index,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                type == 'unwatched' 
                    ? FontAwesomeIcons.videoSlash 
                    : FontAwesomeIcons.checkCircle,
                color: Colors.grey.shade400,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              type == 'unwatched' 
                  ? 'No New Videos' 
                  : 'No Watched Videos',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              type == 'unwatched'
                  ? 'Check back later for new daily videos!'
                  : 'Start watching videos to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseCard(String vId, String videoId, String title, String image, 
      dynamic data, String type, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            dynamic data51 = {
              'type': type,
              'video_id': videoId,
              'description': data["description"],
              'title': title,
              'id': vId,
            };
            Navigator.of(context).pushNamed(
              DailyVideosPlayer.routeName,
              arguments: data51,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Image.network(
                          "${ApiService.websiteUrl2}includes/upload/quotes/$image",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  FontAwesomeIcons.image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          FontAwesomeIcons.play,
                          color: Color(0xFF667EEA),
                          size: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: type == 'watched' 
                              ? Colors.green.withOpacity(0.9)
                              : const Color(0xFF667EEA).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type == 'watched' 
                                  ? FontAwesomeIcons.checkCircle
                                  : FontAwesomeIcons.clock,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              type == 'watched' ? 'Watched' : 'New',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (data["description"] != null && data["description"].isNotEmpty)
                        Text(
                          data["description"],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FontAwesomeIcons.clock,
                                  size: 10,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '5 min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Tap to watch',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667EEA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            FontAwesomeIcons.arrowRight,
                            size: 12,
                            color: Color(0xFF667EEA),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void popup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 20,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFF)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.sliders,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Text(
                          'Filter Categories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          FontAwesomeIcons.xmark,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(20),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          bool isSelected = _selecteCategorys.contains(categories[index]['id']);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF667EEA).withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF667EEA)
                                    : Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: CheckboxListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              activeColor: const Color(0xFF667EEA),
                              checkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              value: isSelected,
                              onChanged: (bool? selected) {
                                setState(() {
                                  selected == true
                                      ? _selecteCategorys.add(categories[index]['id'])
                                      : _selecteCategorys.remove(categories[index]['id']);
                                  myfilter();
                                });
                              },
                              title: Text(
                                categories[index]['category_name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isSelected 
                                      ? const Color(0xFF667EEA)
                                      : Colors.black87,
                                ),
                              ),
                              secondary: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF667EEA)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  FontAwesomeIcons.tag,
                                  size: 16,
                                  color: isSelected ? Colors.white : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selecteCategorys.clear();
                              myfilter();
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667EEA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
