import 'package:carousel_slider/carousel_slider.dart';
import 'package:careerapp/screens/portfolio_gallery_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);
  static const routeName = '/gallery';

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final List<String> images = [];

  int _currentIndex = 0;
  late PageController _pageController;
  var data4 = [];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: _currentIndex);
    getSlider();
  }

  getSlider() async {
    var res = await ApiService.getMethod("/getSchoolPhotos");
    data4 = jsonDecode(res.body);
    for (var element in data4) {
      images.add("${ApiService.websiteUrl2}includes/upload/sliders/" +
          element["slider_image"]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: <Widget>[
        _buildPhotoViewGallery(),
        data4.isEmpty ? const Text("Loading...") : _buildIndicator(),
      ],
    );
  }

  Widget _buildIndicator() {
    return Positioned(
      bottom: 0.0,
      left: 0.0,
      right: 0.0,
      // child: _buildDottedIndicator(),
      child: _buildImageCarouselSlider(),
    );
  }

  Widget _buildImageCarouselSlider() {
    return CarouselSlider.builder(
      options: CarouselOptions(
          height: 100,
          viewportFraction: 0.21,
          enlargeCenterPage: true,
          initialPage: _currentIndex),
      itemCount: images.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
        return PortfolioGalleryImageWidget(
          imagePath: images[itemIndex],
          onImageTap: () {
            _pageController.jumpToPage(itemIndex);
          },
        );
      },
    );
  }

  PhotoViewGallery _buildPhotoViewGallery() {
    return PhotoViewGallery.builder(
      itemCount: images.length,
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(images[index]),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 1.8,
        );
      },
      enableRotation: true,
      scrollPhysics: const BouncingScrollPhysics(),
      pageController: _pageController,
      loadingBuilder: (BuildContext context, ImageChunkEvent? event) {
        return const Center(child: CircularProgressIndicator());
      },
      onPageChanged: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
