import 'dart:convert';
import 'dart:typed_data';

import 'package:starter_app/core/data/constants/app_colors.dart';
import 'package:starter_app/core/global/global_func.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PImage extends StatelessWidget {
  final String source;
  final String? placeholderImage;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final dynamic file;
  final bool? isFile;
  final bool? isProvider;
  final Color? color;
  final bool? isCircle;
  final bool? isPlaceHolderCircle;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isDiffBase64;
  const PImage({
    super.key,
    required this.source,
    this.width,
    this.placeholderImage,
    this.color,
    this.file,
    this.isCircle = false,
    this.isFile = false,
    this.isProvider = false,
    this.isPlaceHolderCircle = false,
    this.height,
    this.fit = BoxFit.fill,
    this.placeholder,
    this.errorWidget,
    this.isDiffBase64 = false,
  });

  bool _isSvg(String path) {
    return path.toLowerCase().endsWith('.svg');
  }

  bool _isUrl(String path) {
    return Uri.tryParse(path)?.hasAbsolutePath ?? false;
  }

  /// Converts a logical width/height (dp) into physical pixels so the
  /// decoder downsamples the bitmap to the size it will actually be
  /// rendered at, instead of decoding at full source resolution.
  /// This is the Flutter equivalent of BitmapFactory.Options.inSampleSize.
  int? _cacheDim(double? logicalSize, double devicePixelRatio) {
    if (logicalSize == null || logicalSize <= 0) return null;
    return (logicalSize * devicePixelRatio).round();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = _cacheDim(width, dpr);
    final cacheHeight = _cacheDim(height, dpr);

    if (isFile ?? false) {
      return file is Uint8List
          ? Image.memory(
              file!,
              width: width,
              height: height,
              fit: fit,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
            )
          : Image.file(
              file,
              width: width,
              height: height,
              fit: fit,
              cacheWidth: cacheWidth,
              cacheHeight: cacheHeight,
            );
    } else if (_isSvg(source)) {
      // SVGs are vector-based and don't suffer from bitmap downsampling
      // issues, so no changes needed here.
      return _isUrl(source)
          ? SvgPicture.network(
              source,
              width: width,
              height: height,
              fit: fit ?? BoxFit.contain,
              placeholderBuilder: (context) =>
                  placeholder ??
                  const Center(child: CircularProgressIndicator()),
            )
          : SvgPicture.asset(
              source,
              width: width,
              height: height,
              colorFilter: color == null
                  ? null
                  : ColorFilter.mode(color!, BlendMode.srcIn),
              fit: fit ?? BoxFit.contain,
            );
    }
    // Render PNG/JPG/GIF image
    else if (_isUrl(source)) {
      return (isProvider ?? false)
          ? Image(
              image: CachedNetworkImageProvider(source),
              height: height,
              width: width,
              fit: fit,
              errorBuilder: (context, error, stackTrace) =>
                  const _ErrorPlaceholder(),
            )
          : ClipOval(
              clipBehavior: isCircle! ? Clip.antiAlias : Clip.none,
              child: CachedNetworkImage(
                imageUrl: source,
                width: width,
                height: height,
                fit: fit,
                // Downsamples the decoded bitmap that's kept in the
                // in-memory cache, matching the widget's display size.
                memCacheWidth: cacheWidth,
                memCacheHeight: cacheHeight,
                placeholder: (context, url) => SizedBox(
                  height: height ?? 45.sp,
                  child:
                      placeholder ??
                      Skeletonizer(
                        enabled: true,
                        child: Container(
                          width: width,
                          height: height,
                          color: isDark
                              ? AppColors.darkFieldBackgroundColor
                              : const Color(0xffEBEBF3),
                        ),
                      ),
                ),
                errorWidget: (context, url, error) =>
                    errorWidget ??
                    ((isPlaceHolderCircle ?? false)
                        ? const ClipOval(
                            clipBehavior: Clip.antiAlias,
                            child: SizedBox(),
                          )
                        : const _ErrorPlaceholder()),
              ),
            );
    } else if (isDiffBase64) {
      return Image.memory(
        base64Decode(source),
        width: width,
        height: height,
        fit: fit ?? BoxFit.fill,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    } else if (isBase64Image(source)) {
      return Image.memory(
        base64Decode(source.split(',')[1]),
        width: width,
        height: height,
        fit: fit ?? BoxFit.fill,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
      );
    } else {
      final assetCacheWidth = (isPlaceHolderCircle ?? false)
          ? _cacheDim(50, dpr)
          : cacheWidth;
      final assetCacheHeight = (isPlaceHolderCircle ?? false)
          ? _cacheDim(50, dpr)
          : cacheHeight;
      return ClipOval(
        clipBehavior: (isPlaceHolderCircle ?? false)
            ? Clip.antiAlias
            : Clip.none,
        child: Image.asset(
          source,
          width: (isPlaceHolderCircle ?? false) ? 50 : width,
          height: (isPlaceHolderCircle ?? false) ? 50 : height,
          fit: fit,
          cacheWidth: assetCacheWidth,
          cacheHeight: assetCacheHeight,
          errorBuilder: (context, error, stackTrace) =>
              (placeholderImage == null || placeholderImage == source)
              ? const _ErrorPlaceholder()
              : PImage(
                  source: placeholderImage!,
                  width: (isPlaceHolderCircle ?? false) ? 100 : width,
                  height: (isPlaceHolderCircle ?? false) ? 100 : height,
                  fit: (isPlaceHolderCircle ?? false)
                      ? BoxFit.cover
                      : BoxFit.fill,
                ),
        ),
      );
    }
  }
}

/// Shown when an image fails to load.
class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.broken_image_outlined, color: AppColors.greyColor),
    );
  }
}
