import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_services.dart';

class ScienceExperiment extends StatefulWidget {
  static const routeName = '/science_experiment';

  const ScienceExperiment({Key? key}) : super(key: key);

  @override
  State<ScienceExperiment> createState() => _ScienceExperimentState();
}

class _ScienceExperimentState extends State<ScienceExperiment> {
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color darkPrimaryColor = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFFFF4081);
  static const Color backgroundColor = Color(0xFFF4F7FC);
  static const Color textPrimaryColor = Color(0xFF1F2937);
  static const Color textSecondaryColor = Color(0xFF6B7280);

  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> experiments = <Map<String, dynamic>>[];

  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool hasError = false;

  String errorMessage = '';
  String selectedClass = 'All';
  String selectedSubject = 'All';

  int currentPage = 1;
  int totalRecords = 0;
  int requestVersion = 0;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    await _loadFirstPage();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 420) {
      _loadMoreExperiments();
    }
  }

  Future<void> _loadFirstPage() async {
    final int activeRequest = ++requestVersion;

    if (mounted) {
      setState(() {
        isLoading = true;
        isLoadingMore = false;
        hasMore = true;
        hasError = false;
        errorMessage = '';
        experiments = <Map<String, dynamic>>[];
        currentPage = 1;
        totalRecords = 0;
      });
    }

    try {
      final _ExperimentPageResult pageResult = await _fetchExperimentPage(
        page: 1,
      );

      if (!mounted || activeRequest != requestVersion) return;

      setState(() {
        experiments = pageResult.items;
        currentPage = pageResult.currentPage;
        totalRecords = pageResult.totalRecords;
        hasMore = pageResult.hasMore;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted || activeRequest != requestVersion) return;

      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage =
            error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadMoreExperiments() async {
    if (isLoading || isLoadingMore || !hasMore) {
      return;
    }

    final int activeRequest = requestVersion;
    final int nextPage = currentPage + 1;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final _ExperimentPageResult pageResult = await _fetchExperimentPage(
        page: nextPage,
      );

      if (!mounted || activeRequest != requestVersion) return;

      setState(() {
        experiments.addAll(pageResult.items);
        currentPage = pageResult.currentPage;
        totalRecords = pageResult.totalRecords;
        hasMore = pageResult.hasMore;
        isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted || activeRequest != requestVersion) return;

      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<_ExperimentPageResult> _fetchExperimentPage({
    required int page,
  }) async {
    final String endpoint =
        '/getScienceExperiment?page=$page&limit=20';

    final response = await ApiService.getMethod3(endpoint);
    final dynamic decodedData = jsonDecode(response.body);

    if (decodedData is! Map || decodedData['error'] != false) {
      throw Exception(
        decodedData is Map && decodedData['message'] != null
            ? decodedData['message'].toString()
            : 'Unable to load science experiments.',
      );
    }

    final List<Map<String, dynamic>> resultItems =
        <Map<String, dynamic>>[];

    if (decodedData['data'] is List) {
      for (final dynamic item in decodedData['data']) {
        resultItems.add(_asMap(item));
      }
    }

    final Map<String, dynamic> pagination =
        _asMap(decodedData['pagination']);

    return _ExperimentPageResult(
      items: resultItems,
      currentPage: _toInt(
        pagination['page'],
        fallback: page,
      ),
      totalRecords: _toInt(
        pagination['total_records'],
        fallback: resultItems.length,
      ),
      hasMore: _toBool(
        pagination['has_more'],
        fallback: false,
      ),
    );
  }

  List<Map<String, dynamic>> get filteredExperiments {
    return experiments.where((item) {
      final String itemClass = _getClassName(item);
      final String itemSubject = _getSubjectName(item);

      final bool classMatched =
          selectedClass == 'All' || itemClass == selectedClass;

      final bool subjectMatched =
          selectedSubject == 'All' || itemSubject == selectedSubject;

      return classMatched && subjectMatched;
    }).toList();
  }

  bool get hasActiveFilters {
    return selectedClass != 'All' || selectedSubject != 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 78,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Science Experiments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Explore, watch and learn',
              style: TextStyle(
                color: Colors.white.withOpacity(0.90),
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Filter experiments',
            onPressed: _showFilterDialog,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                if (hasActiveFilters)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: getData,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: getData,
        backgroundColor: primaryColor,
        elevation: 5,
        icon: const Icon(
          Icons.refresh_rounded,
          color: Colors.white,
        ),
        label: Text(
          'Refresh',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (hasError && experiments.isEmpty) {
      return _buildErrorState();
    }

    if (experiments.isEmpty) {
      return _buildEmptyState();
    }

    return _buildExperimentGrid();
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 330,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 72,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load experiments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                color: textPrimaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: textSecondaryColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              onPressed: getData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.science_outlined,
              size: 76,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No experiments available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                color: textPrimaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New experiments will appear here once they are added.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperimentGrid() {
    final List<Map<String, dynamic>> results = filteredExperiments;

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: getData,
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          double cardHeight = 335;

          if (constraints.maxWidth >= 1150) {
            crossAxisCount = 4;
            cardHeight = 355;
          } else if (constraints.maxWidth >= 760) {
            crossAxisCount = 3;
            cardHeight = 350;
          } else if (constraints.maxWidth >= 540) {
            crossAxisCount = 2;
            cardHeight = 350;
          }

          return CustomScrollView(
            controller: _scrollController,
            cacheExtent: 250,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                  child: _buildTopBanner(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasActiveFilters
                              ? 'Filtered Experiments'
                              : 'All Experiments',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: textPrimaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${results.length} Loaded',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasActiveFilters)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      _filterSummary(),
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildNoFilterResultState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisExtent: cardHeight,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _experimentCard(results[index]);
                      },
                      childCount: results.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: _buildLoadMoreFooter(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, darkPrimaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.22),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.science_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover & Learn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Experiments are loaded in small batches for faster speed.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$totalRecords',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Videos',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.86),
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilterResultState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 65,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 18),
            Text(
              'No matching experiments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: textPrimaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Change your selected filters or load more experiments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreFooter() {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (hasMore) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loadMoreExperiments,
            icon: const Icon(Icons.expand_more_rounded),
            label: Text(
              'Load More Experiments',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(
                color: primaryColor,
                width: 1.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
      child: Center(
        child: Text(
          'All experiments loaded',
          style: TextStyle(
            color: textSecondaryColor,
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _experimentCard(Map<String, dynamic> item) {
    final String topic = _getValue(
      item,
      ['topic', 'title', 'name'],
      fallback: 'Science Experiment',
    );

    final String className = _getClassName(item);
    final String subjectName = _getSubjectName(item);
    final String imageName = _getValue(item, ['image']);
    final String dateText = _formatDate(
      _getValue(item, ['created', 'date']),
    );
    final String url = _getValue(item, ['url', 'video_url', 'link']);

    final Color subjectColor = _getSubjectColor(subjectName);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openExperiment(url),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExperimentImage(
                    imageName: imageName,
                    className: className,
                    subjectColor: subjectColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              height: 1.25,
                              color: textPrimaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 15,
                                color: textSecondaryColor.withOpacity(0.85),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  dateText,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    color: textSecondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: subjectColor.withOpacity(0.11),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_fill_rounded,
                                  size: 18,
                                  color: subjectColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Watch Now',
                                  style: TextStyle(
                                    color: subjectColor,
                                    fontSize: 9.8.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExperimentImage({
    required String imageName,
    required String className,
    required Color subjectColor,
  }) {
    final String imageUrl = _resolveImageUrl(imageName);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double pixelRatio =
            MediaQuery.of(context).devicePixelRatio;

        final int cacheWidth =
            (constraints.maxWidth * pixelRatio)
                .clamp(360.0, 800.0)
                .round();

        return SizedBox(
          height: 132,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl.isEmpty)
                _buildImageFallback(subjectColor)
              else
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,

                  // Lower memory usage + disk cache.
                  memCacheWidth: cacheWidth,
                  maxWidthDiskCache: cacheWidth,
                  maxHeightDiskCache: 520,

                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  useOldImageOnUrlChange: true,

                  placeholder: (context, url) {
                    return _buildImageFallback(subjectColor);
                  },
                  errorWidget: (context, url, error) {
                    return _buildImageFallback(subjectColor);
                  },
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.38),
                    ],
                    stops: const [0.55, 1],
                  ),
                ),
              ),
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.94),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: accentColor,
                    size: 26,
                  ),
                ),
              ),
              Positioned(
                left: 9,
                bottom: 9,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.93),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    className.isEmpty ? 'Science' : className,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageFallback(Color subjectColor) {
    return Container(
      color: subjectColor.withOpacity(0.10),
      child: Center(
        child: Icon(
          Icons.science_outlined,
          size: 44,
          color: subjectColor,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final List<String> classOptions =
        _getAvailableOptions(_getClassName);

    final List<String> subjectOptions =
        _getAvailableOptions(_getSubjectName);

    String temporaryClass = selectedClass;
    String temporarySubject = selectedSubject;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 78.h,
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 52,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Filter Experiments',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: textPrimaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Select Class',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: textPrimaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: classOptions.map((item) {
                          final bool selected = temporaryClass == item;

                          return ChoiceChip(
                            label: Text(
                              item,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            selected: selected,
                            selectedColor:
                                primaryColor.withOpacity(0.14),
                            backgroundColor: Colors.grey.shade100,
                            side: BorderSide(
                              color: selected
                                  ? primaryColor
                                  : Colors.grey.shade300,
                            ),
                            onSelected: (_) {
                              setModalState(() {
                                temporaryClass = item;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Select Subject',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: textPrimaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: subjectOptions.map((item) {
                          final bool selected = temporarySubject == item;

                          return ChoiceChip(
                            label: Text(
                              item,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            selected: selected,
                            selectedColor:
                                primaryColor.withOpacity(0.14),
                            backgroundColor: Colors.grey.shade100,
                            side: BorderSide(
                              color: selected
                                  ? primaryColor
                                  : Colors.grey.shade300,
                            ),
                            onSelected: (_) {
                              setModalState(() {
                                temporarySubject = item;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  temporaryClass = 'All';
                                  temporarySubject = 'All';
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                minimumSize: const Size(0, 50),
                                side: const BorderSide(
                                  color: primaryColor,
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Reset',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedClass = temporaryClass;
                                  selectedSubject = temporarySubject;
                                });

                                Navigator.pop(sheetContext);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                'Apply Filter',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _getAvailableOptions(
    String Function(Map<String, dynamic>) valueGetter,
  ) {
    final Set<String> values = <String>{};

    for (final Map<String, dynamic> item in experiments) {
      final String value = valueGetter(item);

      if (value.trim().isNotEmpty) {
        values.add(value);
      }
    }

    final List<String> sortedValues = values.toList()..sort();

    return <String>['All', ...sortedValues];
  }

  String _filterSummary() {
    final List<String> filters = <String>[];

    if (selectedClass != 'All') {
      filters.add('Class: $selectedClass');
    }

    if (selectedSubject != 'All') {
      filters.add('Subject: $selectedSubject');
    }

    return filters.join('   •   ');
  }

  Future<void> _openExperiment(String url) async {
    if (url.trim().isEmpty) {
      _showMessage('Experiment video link is not available.');
      return;
    }

    try {
      final bool canOpen = await canLaunch(url);

      if (!canOpen) {
        _showMessage('Unable to open this experiment link.');
        return;
      }

      await launch(url);
    } catch (_) {
      _showMessage('Unable to open this experiment link.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: textPrimaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item;
    }

    if (item is Map) {
      return item.map(
        (key, value) => MapEntry<String, dynamic>(
          key.toString(),
          value,
        ),
      );
    }

    return <String, dynamic>{};
  }

  int _toInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool _toBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;

    final String parsed = value?.toString().toLowerCase() ?? '';

    if (parsed == 'true' || parsed == '1') return true;
    if (parsed == 'false' || parsed == '0') return false;

    return fallback;
  }

  String _getValue(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final String key in keys) {
      final dynamic value = item[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
  }

  String _getClassName(Map<String, dynamic> item) {
    return _getValue(
      item,
      ['class', 'class_name', 'grade', 'class_for'],
    );
  }

  String _getSubjectName(Map<String, dynamic> item) {
    return _getValue(
      item,
      ['subject_name', 'subject', 'category'],
    );
  }

  String _formatDate(String date) {
    if (date.trim().isEmpty) {
      return 'Recently added';
    }

    try {
      final DateTime? parsed = DateTime.tryParse(date);

      if (parsed == null) return date;

      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }

  String _resolveImageUrl(String imageName) {
    final String fileName = imageName.trim();

    if (fileName.isEmpty) {
      return '';
    }

    if (fileName.startsWith('http://') ||
        fileName.startsWith('https://')) {
      return fileName;
    }

    String baseUrl = ApiService.careerdefenceacademy2;

    if (!baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    return '${baseUrl}includes/uploads/science_experiment/'
        '${Uri.encodeComponent(fileName)}';
  }

  Color _getSubjectColor(String subject) {
    const Map<String, Color> subjectColors = <String, Color>{
      'mathematics': Color(0xFF1E88E5),
      'math': Color(0xFF1E88E5),
      'science': Color(0xFF43A047),
      'english': Color(0xFF8E24AA),
      'hindi': Color(0xFFEF6C00),
      'social_science': Color(0xFFE53935),
      'social studies': Color(0xFFE53935),
      'physics': Color(0xFF3949AB),
      'chemistry': Color(0xFF00897B),
      'biology': Color(0xFF7CB342),
      'computer': Color(0xFF00ACC1),
    };

    final String lowerSubject = subject.toLowerCase();

    for (final String key in subjectColors.keys) {
      if (lowerSubject.contains(key)) {
        return subjectColors[key]!;
      }
    }

    return primaryColor;
  }
}

class _ExperimentPageResult {
  final List<Map<String, dynamic>> items;
  final int currentPage;
  final int totalRecords;
  final bool hasMore;

  const _ExperimentPageResult({
    required this.items,
    required this.currentPage,
    required this.totalRecords,
    required this.hasMore,
  });
}