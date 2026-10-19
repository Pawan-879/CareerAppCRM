import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_services.dart';

class Messmenu extends StatefulWidget {
  const Messmenu({Key? key}) : super(key: key);

  @override
  State<Messmenu> createState() => _MessmenuState();
}

class _MessmenuState extends State<Messmenu>
    with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFFFF8A00);
  static const Color darkOrange = Color(0xFFE86800);
  static const Color pageBackground = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF202938);
  static const Color textLight = Color(0xFF6F7785);

  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _menus = <Map<String, dynamic>>[];

  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  String _errorMessage = '';

  int _selectedSchoolId = 1;
  int _currentPage = 1;
  int _requestId = 0;

  String _selectedMenuType = 'all';
  String _selectedMealType = 'all';

  final List<_SchoolTabData> _schoolTabs = const <_SchoolTabData>[
    _SchoolTabData(
      id: 1,
      label: 'AMBALA',
      icon: Icons.location_on_rounded,
    ),
    _SchoolTabData(
      id: 2,
      label: 'YAMUNANAGAR',
      icon: Icons.location_on_rounded,
    ),
    _SchoolTabData(
      id: 3,
      label: 'PATIALA',
      icon: Icons.location_on_rounded,
    ),
    _SchoolTabData(
      id: 4,
      label: 'DAILY VEGETABLES',
      icon: Icons.eco_rounded,
    ),
    _SchoolTabData(
      id: 5,
      label: 'DAILY MENUS',
      icon: Icons.restaurant_menu_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: _schoolTabs.length,
      vsync: this,
    );

    _scrollController.addListener(_handleScroll);
    getData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    await _loadFirstPage();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 350) {
      _loadMoreMenus();
    }
  }

  Future<void> _loadFirstPage() async {
    final int activeRequestId = ++_requestId;

    if (mounted) {
      setState(() {
        _isLoadingInitial = true;
        _isLoadingMore = false;
        _errorMessage = '';
        _menus = <Map<String, dynamic>>[];
        _currentPage = 1;
        _hasMore = true;
      });
    }

    try {
      final _MenuPageResult pageResult = await _fetchMenuPage(page: 1);

      if (!mounted || activeRequestId != _requestId) return;

      setState(() {
        _menus = pageResult.items;
        _currentPage = pageResult.currentPage;
        _hasMore = pageResult.hasMore;
        _isLoadingInitial = false;
      });
    } catch (error) {
      if (!mounted || activeRequestId != _requestId) return;

      setState(() {
        _isLoadingInitial = false;
        _errorMessage =
            error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadMoreMenus() async {
    if (_isLoadingInitial || _isLoadingMore || !_hasMore) {
      return;
    }

    final int activeRequestId = _requestId;
    final int nextPage = _currentPage + 1;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final _MenuPageResult pageResult = await _fetchMenuPage(
        page: nextPage,
      );

      if (!mounted || activeRequestId != _requestId) return;

      setState(() {
        _menus.addAll(pageResult.items);
        _currentPage = pageResult.currentPage;
        _hasMore = pageResult.hasMore;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted || activeRequestId != _requestId) return;

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<_MenuPageResult> _fetchMenuPage({
    required int page,
  }) async {
    final String endpoint =
        '/getMessMenu'
        '?school_id=$_selectedSchoolId'
        '&page=$page'
        '&limit=20'
        '&menu_type=$_selectedMenuType'
        '&meal_type=$_selectedMealType';

    final response = await ApiService.getMethod3(endpoint);
    final dynamic decodedData = jsonDecode(response.body);

    if (decodedData is! Map || decodedData['error'] != false) {
      throw Exception(
        decodedData is Map && decodedData['message'] != null
            ? decodedData['message'].toString()
            : 'Unable to load mess menu.',
      );
    }

    final List<Map<String, dynamic>> menuItems = <Map<String, dynamic>>[];

    if (decodedData['data'] is List) {
      for (final dynamic item in decodedData['data']) {
        menuItems.add(_asMap(item));
      }
    }

    final Map<String, dynamic> pagination =
        _asMap(decodedData['pagination']);

    return _MenuPageResult(
      items: menuItems,
      currentPage: _toInt(
        pagination['page'],
        fallback: page,
      ),
      hasMore: _toBool(
        pagination['has_more'],
        fallback: false,
      ),
    );
  }

  String get _currentSchoolName {
    return _schoolTabs
        .firstWhere((tab) => tab.id == _selectedSchoolId)
        .label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 80,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 23,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Mess Menu',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Fresh and nutritious meals every day',
              style: TextStyle(
                color: Colors.white.withOpacity(0.90),
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh menu',
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 29,
            ),
            onPressed: getData,
          ),
          const SizedBox(width: 7),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            height: 64,
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: primaryColor,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              labelPadding: const EdgeInsets.symmetric(horizontal: 15),
              onTap: (index) {
                setState(() {
                  _selectedSchoolId = _schoolTabs[index].id;
                  _selectedMenuType = 'all';
                  _selectedMealType = 'all';
                });

                getData();
              },
              tabs: _schoolTabs.map((school) {
                return Tab(
                  height: 64,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(school.icon, size: 20),
                      const SizedBox(width: 5),
                      Text(
                        school.label,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTopInfoCard(),
          _buildFilters(),
          Expanded(child: _buildContent()),
        ],
      ),
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
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildTopInfoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, darkOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentSchoolName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Swipe photos inside each menu card to view all food images.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 10.5.sp,
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
              horizontal: 11,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.17),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  '${_menus.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Loaded',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 9.sp,
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

  Widget _buildFilters() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Menu',
            style: TextStyle(
              color: textDark,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 11),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All',
                  selected: _selectedMenuType == 'all',
                  onTap: () => _changeMenuType('all'),
                ),
                _buildFilterChip(
                  label: 'Daily',
                  selected: _selectedMenuType == 'daily',
                  onTap: () => _changeMenuType('daily'),
                ),
                _buildFilterChip(
                  label: 'Weekly',
                  selected: _selectedMenuType == 'weekly',
                  onTap: () => _changeMenuType('weekly'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'All Meals',
                  selected: _selectedMealType == 'all',
                  onTap: () => _changeMealType('all'),
                ),
                _buildFilterChip(
                  label: 'Breakfast',
                  selected: _selectedMealType == 'breakfast',
                  onTap: () => _changeMealType('breakfast'),
                ),
                _buildFilterChip(
                  label: 'Lunch',
                  selected: _selectedMealType == 'lunch',
                  onTap: () => _changeMealType('lunch'),
                ),
                _buildFilterChip(
                  label: 'Snacks',
                  selected: _selectedMealType == 'snacks',
                  onTap: () => _changeMealType('snacks'),
                ),
                _buildFilterChip(
                  label: 'Dinner',
                  selected: _selectedMealType == 'dinner',
                  onTap: () => _changeMealType('dinner'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _changeMenuType(String menuType) {
    if (_selectedMenuType == menuType) return;

    setState(() {
      _selectedMenuType = menuType;

      if (menuType == 'weekly') {
        _selectedMealType = 'all';
      }
    });

    getData();
  }

  void _changeMealType(String mealType) {
    if (_selectedMealType == mealType) return;

    setState(() {
      _selectedMealType = mealType;

      if (mealType != 'all') {
        _selectedMenuType = 'daily';
      }
    });

    getData();
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected ? primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: selected ? primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : textLight,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoadingInitial) {
      return _buildLoadingList();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_menus.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: getData,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 0,
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 115),
        itemCount: _menus.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildListHeader();
          }

          final int menuIndex = index - 1;

          if (menuIndex < _menus.length) {
            return _buildMenuCard(_menus[menuIndex]);
          }

          return _buildLoadMoreFooter();
        },
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Available Menus',
              style: TextStyle(
                color: textDark,
                fontSize: 16.5.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_menus.length} Records',
              style: TextStyle(
                color: primaryColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreFooter() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (!_hasMore) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        child: Center(
          child: Text(
            'All menu records loaded',
            style: TextStyle(
              color: textLight,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 35);
  }

  Widget _buildMenuCard(Map<String, dynamic> item) {
    final String menuType = _value(
      item,
      ['menu_type'],
      fallback: 'menu',
    ).toLowerCase();

    final String day = _value(item, ['day']);
    final String topic = _value(item, ['topic']);
    final String mealType = _value(item, ['meal_type']).toLowerCase();

    final bool isDaily = menuType == 'daily';

    final String title = isDaily
        ? (day.isNotEmpty ? _toTitle(day) : 'Daily Menu')
        : (topic.isNotEmpty ? topic : 'Weekly Menu');

    final String subtitle = isDaily
        ? (mealType.isNotEmpty ? _toTitle(mealType) : 'Meal Menu')
        : _toTitle(menuType);

    final String menuDate = _formatDate(
      _value(
        item,
        ['menu_date'],
        fallback: _value(item, ['created']),
      ),
    );

    final List<String> images = _getImageList(item);
    final List<String> menuItems = _getMenuItems(item);
    final String url = _value(item, ['url']);

    final Color mealColor = _getMealColor(mealType);
    final IconData mealIcon = _getMealIcon(mealType);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(21),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 13,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (images.isNotEmpty)
                _MenuImageSlider(
                  images: images,
                  accentColor: mealColor,
                  imageUrlBuilder: _resolveImageUrl,
                  onOpenGallery: (selectedIndex) {
                    _openImageGallery(images, selectedIndex);
                  },
                )
              else
                _buildNoImageHeader(
                  color: mealColor,
                  icon: mealIcon,
                ),
              Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textDark,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _toTitle(menuType),
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: mealColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            mealIcon,
                            size: 19,
                            color: mealColor,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              color: mealColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (menuDate.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 18,
                                color: textLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                menuDate,
                                style: TextStyle(
                                  color: textLight,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (menuItems.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        'Menu Items',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: menuItems.map((menuItem) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: mealColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: mealColor.withOpacity(0.20),
                              ),
                            ),
                            child: Text(
                              menuItem.replaceAll('_', ' '),
                              style: TextStyle(
                                color: textDark,
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (url.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _openUrl(url),
                          icon: const Icon(
                            Icons.open_in_new_rounded,
                            size: 20,
                          ),
                          label: Text(
                            isDaily
                                ? 'View Full Menu Details'
                                : 'Open Weekly Menu',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoImageHeader({
    required Color color,
    required IconData icon,
  }) {
    return Container(
      height: 220,
      width: double.infinity,
      color: color.withOpacity(0.10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 58,
            color: color,
          ),
          const SizedBox(height: 10),
          Text(
            'Menu Image Not Available',
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 100),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          height: 300,
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: primaryColor.withOpacity(0.75),
            ),
          ),
        );
      },
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
              Icons.no_food_rounded,
              size: 78,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            Text(
              'No Menu Items Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing the selected filter or refresh this page.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textLight,
                fontSize: 11.5.sp,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 21),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedMenuType = 'all';
                  _selectedMealType = 'all';
                });

                getData();
              },
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(
                'Clear Filters',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(
                  color: primaryColor,
                  width: 1.4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 21,
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              color: Colors.red.shade400,
              size: 74,
            ),
            const SizedBox(height: 18),
            Text(
              'Unable to Load Menu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textLight,
                fontSize: 11.sp,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 21),
            ElevatedButton.icon(
              onPressed: getData,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
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

  void _openImageGallery(
    List<String> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.88),
      builder: (context) {
        return _FullScreenImageGallery(
          images: images,
          initialIndex: initialIndex,
          imageUrlBuilder: _resolveImageUrl,
        );
      },
    );
  }

  Map<String, dynamic> _asMap(dynamic rawItem) {
    if (rawItem is Map<String, dynamic>) {
      return rawItem;
    }

    if (rawItem is Map) {
      return rawItem.map(
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

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool _toBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;

    final String normalized = value?.toString().toLowerCase() ?? '';

    if (normalized == '1' || normalized == 'true') return true;
    if (normalized == '0' || normalized == 'false') return false;

    return fallback;
  }

  String _value(
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

  List<String> _getImageList(Map<String, dynamic> item) {
    final dynamic imageListFromApi = item['image_list'];

    if (imageListFromApi is List) {
      return imageListFromApi
          .map((image) => image.toString().trim())
          .where((image) => image.isNotEmpty)
          .toList();
    }

    final String rawImages = _value(item, ['image']);

    if (rawImages.isEmpty) {
      return <String>[];
    }

    return rawImages
        .split(',')
        .map((image) => image.trim())
        .where((image) => image.isNotEmpty)
        .toList();
  }

  List<String> _getMenuItems(Map<String, dynamic> item) {
    final dynamic menuItemsFromApi = item['menu_items'];

    if (menuItemsFromApi is List) {
      return menuItemsFromApi
          .map((menuItem) => menuItem.toString().trim())
          .where(
            (menuItem) => menuItem.isNotEmpty && menuItem != '.',
          )
          .toList();
    }

    final String rawMenu = _value(item, ['menu']);

    if (rawMenu.isEmpty || rawMenu == '.') {
      return <String>[];
    }

    try {
      final dynamic decodedMenu = jsonDecode(rawMenu);

      if (decodedMenu is List) {
        return decodedMenu
            .map((menuItem) => menuItem.toString().trim())
            .where(
              (menuItem) => menuItem.isNotEmpty && menuItem != '.',
            )
            .toList();
      }
    } catch (_) {}

    return rawMenu
        .split(',')
        .map((menuItem) => menuItem.trim())
        .where(
          (menuItem) => menuItem.isNotEmpty && menuItem != '.',
        )
        .toList();
  }

  String _resolveImageUrl(String imageName) {
    final String cleanImageName = imageName.trim();

    if (cleanImageName.startsWith('http://') ||
        cleanImageName.startsWith('https://')) {
      return cleanImageName;
    }

    String baseUrl = ApiService.careerdefenceacademy2;

    if (!baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    return '$baseUrl'
        'includes/uploads/mess_menu/'
        '${Uri.encodeComponent(cleanImageName)}';
  }

  Future<void> _openUrl(String rawUrl) async {
    final String url = rawUrl.trim();

    if (url.isEmpty) {
      _showMessage('Menu link is not available.');
      return;
    }

    final Uri? uri = Uri.tryParse(url);

    if (uri == null) {
      _showMessage('Invalid menu link.');
      return;
    }

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage('Unable to open this menu link.');
      }
    } catch (_) {
      _showMessage('Unable to open this menu link.');
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
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: textDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatDate(String rawDate) {
    if (rawDate.trim().isEmpty ||
        rawDate == '0000-00-00' ||
        rawDate.toLowerCase() == 'null') {
      return '';
    }

    try {
      final DateTime? parsedDate = DateTime.tryParse(rawDate);

      if (parsedDate == null) {
        return rawDate;
      }

      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (_) {
      return rawDate;
    }
  }

  String _toTitle(String value) {
    if (value.trim().isEmpty) return '';

    return value
        .trim()
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';

          return '${word[0].toUpperCase()}'
              '${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  Color _getMealColor(String mealType) {
    final String type = mealType.toLowerCase();

    if (type.contains('breakfast')) {
      return const Color(0xFFFF9800);
    }

    if (type.contains('lunch')) {
      return const Color(0xFF2E7D32);
    }

    if (type.contains('snack')) {
      return const Color(0xFFAD1457);
    }

    if (type.contains('dinner')) {
      return const Color(0xFF3949AB);
    }

    return primaryColor;
  }

  IconData _getMealIcon(String mealType) {
    final String type = mealType.toLowerCase();

    if (type.contains('breakfast')) {
      return Icons.free_breakfast_rounded;
    }

    if (type.contains('lunch')) {
      return Icons.lunch_dining_rounded;
    }

    if (type.contains('snack')) {
      return Icons.bakery_dining_rounded;
    }

    if (type.contains('dinner')) {
      return Icons.dinner_dining_rounded;
    }

    return Icons.restaurant_rounded;
  }
}

class _MenuPageResult {
  final List<Map<String, dynamic>> items;
  final int currentPage;
  final bool hasMore;

  const _MenuPageResult({
    required this.items,
    required this.currentPage,
    required this.hasMore,
  });
}

class _SchoolTabData {
  final int id;
  final String label;
  final IconData icon;

  const _SchoolTabData({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _MenuImageSlider extends StatefulWidget {
  final List<String> images;
  final Color accentColor;
  final String Function(String) imageUrlBuilder;
  final ValueChanged<int> onOpenGallery;

  const _MenuImageSlider({
    required this.images,
    required this.accentColor,
    required this.imageUrlBuilder,
    required this.onOpenGallery,
  });

  @override
  State<_MenuImageSlider> createState() => _MenuImageSliderState();
}

class _MenuImageSliderState extends State<_MenuImageSlider> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToImage(int index) {
    if (index < 0 || index >= widget.images.length) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double devicePixelRatio =
        MediaQuery.of(context).devicePixelRatio;

    final int cacheWidth =
        (screenWidth * devicePixelRatio).clamp(700.0, 1100.0).round();

    final bool hasMultipleImages = widget.images.length > 1;

    return SizedBox(
      height: 235,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(21),
            ),
            child: GestureDetector(
              onTap: () => widget.onOpenGallery(_currentImageIndex),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                physics: hasMultipleImages
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final String imageUrl =
                      widget.imageUrlBuilder(widget.images[index]);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: cacheWidth,
                        maxWidthDiskCache: cacheWidth,
                        maxHeightDiskCache: 700,
                        fadeInDuration:
                            const Duration(milliseconds: 120),
                        fadeOutDuration: Duration.zero,
                        useOldImageOnUrlChange: true,
                        placeholder: (context, url) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                                strokeWidth: 3,
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            color: widget.accentColor.withOpacity(0.10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 52,
                                  color: widget.accentColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(
                                    color: widget.accentColor,
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.48),
                            ],
                            stops: const [0.55, 1],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.60),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${_currentImageIndex + 1} / ${widget.images.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (hasMultipleImages)
            Positioned(
              bottom: 13,
              left: 0,
              right: 0,
              child: Center(
                child: _buildIndicatorDots(),
              ),
            ),

          if (hasMultipleImages && _currentImageIndex > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildSlideButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _goToImage(_currentImageIndex - 1),
                ),
              ),
            ),

          if (hasMultipleImages &&
              _currentImageIndex < widget.images.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildSlideButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _goToImage(_currentImageIndex + 1),
                ),
              ),
            ),

          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.zoom_in_rounded,
                    size: 18,
                    color: widget.accentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'View Photos',
                    style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            icon,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorDots() {
    if (widget.images.length > 8) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.48),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Swipe to see all photos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.images.length, (index) {
        final bool selected = index == _currentImageIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: selected ? 18 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String Function(String) imageUrlBuilder;

  const _FullScreenImageGallery({
    required this.images,
    required this.initialIndex,
    required this.imageUrlBuilder,
  });

  @override
  State<_FullScreenImageGallery> createState() =>
      _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState
    extends State<_FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToImage(int index) {
    if (index < 0 || index >= widget.images.length) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double devicePixelRatio =
        MediaQuery.of(context).devicePixelRatio;

    final int cacheWidth =
        (screenWidth * devicePixelRatio).clamp(900.0, 1600.0).round();

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.78,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final String imageUrl =
                    widget.imageUrlBuilder(widget.images[index]);

                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      memCacheWidth: cacheWidth,
                      maxWidthDiskCache: cacheWidth,
                      fadeInDuration:
                          const Duration(milliseconds: 150),
                      placeholder: (context, url) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 60,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            if (widget.images.length > 1 && _currentIndex > 0)
              Positioned(
                left: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () => _goToImage(_currentIndex - 1),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),

            if (widget.images.length > 1 &&
                _currentIndex < widget.images.length - 1)
              Positioned(
                right: 4,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () => _goToImage(_currentIndex + 1),
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}