import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:starter_app/core/data/constants/app_colors.dart';
import 'package:starter_app/core/global/enums/global_enum.dart';

class CustomLoader extends StatelessWidget {
  final LoadingShape loadingShape;
  final double size;
  final Color? color;

  const CustomLoader({
    super.key,
    this.loadingShape = LoadingShape.wave,
    this.color,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    switch (loadingShape) {
      case LoadingShape.wave:
        return SpinKitWave(
          color: AppColors.primaryColor,
          size: size,
          itemCount: 8,
        );
      case LoadingShape.waveSpinner:
        return SpinKitWaveSpinner(
          color: color ?? AppColors.primaryColor,
          size: size,
        );
      case LoadingShape.fadingCircle:
        return SpinKitFadingCircle(
          color: color ?? AppColors.primaryColor,
          size: size,
        );
      case LoadingShape.cubeGrid:
        return SpinKitCubeGrid(
          color: color ?? AppColors.primaryColor,
          size: size,
        );
      case LoadingShape.foldingCube:
        return SpinKitFoldingCube(
          color: color ?? AppColors.primaryColor,
          size: size,
        );
      case LoadingShape.pouringHourGlassRefined:
        return SpinKitPouringHourGlassRefined(
          color: AppColors.primaryColor,
          size: size,
        );
      default:
        return SpinKitWave(
          color: color ?? AppColors.primaryColor,
          size: size,
          itemCount: 8,
        );
    }
  }
}
