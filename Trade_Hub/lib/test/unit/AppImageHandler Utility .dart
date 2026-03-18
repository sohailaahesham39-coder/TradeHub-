import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class AppImageHandler {
  // Custom cache manager for better control over caching
  static final customCacheManager = CacheManager(
    Config(
      'tradeHubCacheKey',
      stalePeriod: const Duration(days: 14), // Increased cache duration to 14 days
      maxNrOfCacheObjects: 200, // Increased cache capacity
      repo: JsonCacheInfoRepository(databaseName: 'tradeHubCache'),
      fileService: HttpFileService(),
    ),
  );

  // Load a network image with caching, shimmer loading, and error fallback
  static Widget loadNetworkImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    IconData placeholderIcon = Icons.image,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    bool useShimmerLoading = true,
    Duration fadeDuration = const Duration(milliseconds: 300),
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
  }) {
    if (!isValidImageUrl(imageUrl)) {
      return _buildErrorWidget(
        width: width,
        height: height,
        backgroundColor: backgroundColor,
        placeholderIcon: placeholderIcon,
        borderRadius: borderRadius,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        cacheManager: customCacheManager,
        fadeInDuration: fadeDuration,
        placeholder: (context, url) => useShimmerLoading
            ? _buildShimmerLoading(
          width,
          height,
          backgroundColor,
          baseColor: shimmerBaseColor,
          highlightColor: shimmerHighlightColor,
        )
            : _buildSimpleLoading(width, height, backgroundColor, context),
        errorWidget: (context, url, error) => _buildErrorWidget(
          width: width,
          height: height,
          backgroundColor: backgroundColor,
          placeholderIcon: placeholderIcon,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  // Enhanced shimmer loading effect with custom colors
  static Widget _buildShimmerLoading(
      double? width,
      double? height,
      Color? backgroundColor, {
        Color? baseColor,
        Color? highlightColor,
      }) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? backgroundColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  // Simple loading spinner with improved aesthetics
  static Widget _buildSimpleLoading(double? width, double? height, Color? backgroundColor, BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.h,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  // Error widget with icon fallback and optional border radius
  static Widget _buildErrorWidget({
    double? width,
    double? height,
    Color? backgroundColor,
    IconData placeholderIcon = Icons.image,
    BorderRadius? borderRadius,
  }) {
    final Widget errorContent = Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey.shade200,
      child: Center(
        child: Icon(
          placeholderIcon,
          color: Colors.grey.shade400,
          size: (width != null && height != null)
              ? (width < height ? width * 0.3 : height * 0.3)
              : 40.sp,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: errorContent,
      );
    }

    return errorContent;
  }

  // Load profile images (circular) with improved styling
  static Widget loadProfileImage({
    required String imageUrl,
    double size = 40,
    IconData placeholderIcon = Icons.person,
    bool useShimmerLoading = true,
    Color borderColor = Colors.white,
    double borderWidth = 2,
    bool showBorder = true,
  }) {
    final Widget image = loadNetworkImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholderIcon: placeholderIcon,
      borderRadius: BorderRadius.circular(size / 2),
      useShimmerLoading: useShimmerLoading,
    );

    if (showBorder) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: image,
      );
    }

    return image;
  }

  // Enhanced product image loading with optional shadow effects
  static Widget loadProductImage({
    required String imageUrl,
    double width = 120,
    double height = 120,
    BorderRadius? borderRadius,
    bool showShadow = false,
    BoxFit fit = BoxFit.cover,
    Color? shimmerBaseColor,
    Color? shimmerHighlightColor,
  }) {
    Widget image = loadNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholderIcon: Icons.inventory_2_outlined,
      borderRadius: borderRadius ?? BorderRadius.circular(12.r),
      backgroundColor: Colors.grey.shade100,
      shimmerBaseColor: shimmerBaseColor,
      shimmerHighlightColor: shimmerHighlightColor,
    );

    if (showShadow) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              spreadRadius: 1.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: image,
      );
    }

    return image;
  }

  // Enhanced event banner images with customizable overlay gradient
  static Widget loadEventImage({
    required String imageUrl,
    double? width,
    double height = 180,
    BorderRadius? borderRadius,
    Widget? overlayContent,
    List<Color>? gradientColors,
    Alignment? gradientBegin,
    Alignment? gradientEnd,
  }) {
    Widget image = loadNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      placeholderIcon: Icons.event_note,
      borderRadius: borderRadius ?? BorderRadius.circular(16.r),
    );

    if (overlayContent != null) {
      return Stack(
        children: [
          image,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: gradientBegin ?? Alignment.topCenter,
                  end: gradientEnd ?? Alignment.bottomCenter,
                  colors: gradientColors ?? [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(child: overlayContent),
        ],
      );
    }

    return image;
  }

  // Enhanced category/icon images with customizable shadow
  static Widget loadCategoryIcon({
    required String imageUrl,
    double size = 60,
    Color backgroundColor = Colors.white,
    IconData placeholderIcon = Icons.category_outlined,
    Color iconColor = Colors.grey,
    double elevation = 2,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r * elevation,
            spreadRadius: 1.r * (elevation / 2),
            offset: Offset(0, 2.h * (elevation / 2)),
          ),
        ],
      ),
      child: loadNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholderIcon: placeholderIcon,
        borderRadius: BorderRadius.circular(size / 2),
        useShimmerLoading: false,
      ),
    );
  }

  // Preload multiple images with progress callback
  static Future<void> preloadImages(
      BuildContext context,
      List<String> imageUrls, {
        Function(int loaded, int total)? onProgress,
      }) async {
    int loaded = 0;
    final total = imageUrls.length;

    for (var url in imageUrls) {
      if (isValidImageUrl(url)) {
        await precacheImage(
            CachedNetworkImageProvider(url, cacheManager: customCacheManager),
            context
        );
        loaded++;
        if (onProgress != null) {
          onProgress(loaded, total);
        }
      }
    }
  }

  // Check if image URL is valid
  static bool isValidImageUrl(String url) {
    return url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'));
  }

  // Load image with fallback to local assets
  static Widget loadImageWithFallback({
    required String imageUrl,
    required String fallbackAsset,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    bool useShimmerLoading = true,
  }) {
    if (isValidImageUrl(imageUrl)) {
      return loadNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        useShimmerLoading: useShimmerLoading,
      );
    } else {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.asset(
          fallbackAsset,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(
            width: width,
            height: height,
            backgroundColor: Colors.grey.shade200,
            borderRadius: borderRadius,
          ),
        ),
      );
    }
  }
}