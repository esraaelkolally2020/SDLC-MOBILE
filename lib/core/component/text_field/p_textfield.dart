import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/constants/app_colors.dart';
import '../../global/enums/global_enum.dart';
import '../../services/localization/app_localization.dart';
import '../image/p_image.dart';
import '../text/p_text.dart';

class PTextField extends StatefulWidget {
  final String? hintText, errorText, obscuringCharacter;
  final String? initialText;
  final String? labelAbove;
  final String? labelInside;
  final bool isFieldRequired;
  final PSize? labelAboveFontSize;
  final FontWeight? labelAboveFontWeight;
  final Color? textColor,
      labelAboveColor,
      hintColor,
      fillColor,
      borderColor,
      disabledBorderColor,
      focusedColor,
      errorBorderColor;
  final bool isObscured;
  final bool isPassword;
  final double? borderRadius;
  final TextEditingController? controller;
  final int? maxLines;
  final FontWeight? fontWeight;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final bool? isDense;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? textInputType;
  final double? fontSize;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final InputBorder? focusInputBorder;
  final InputBorder? enabledInputBorder;
  final EdgeInsetsGeometry? contentPadding;
  final GlobalKey<FormState>? formKey;
  final ValueChanged<String>? feedback;
  final String? Function(String? value)? validator;
  final bool isHasSpecialCharcters;
  final FocusNode? currentFocus;
  final FocusNode? nextFocus;
  final bool isOptional;
  final String? sourcePrefixImage;
  final String? sourceSuffixImage;
  final Color? sourceSuffixImageColor;
  final bool trimOnChange; // 👈 جديد
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? disabledBorder;
  final InputBorder? focusedErrorBorder;
  final InputBorder? errorBorder;
  final double? height;
  const PTextField({
    super.key,
    this.labelAbove,
    this.sourceSuffixImageColor,
    this.labelInside,
    this.labelAboveFontSize,
    this.labelAboveFontWeight,
    this.suffixIcon,
    this.hintText,
    this.isFieldRequired = false,
    this.inputFormatters,
    this.textInputType = TextInputType.text,
    this.textColor,
    this.textInputAction,
    this.labelAboveColor,
    this.focusInputBorder,
    this.contentPadding,
    this.enabledInputBorder,
    required this.feedback,
    this.fillColor,
    this.focusedColor,
    this.borderColor,
    this.disabledBorderColor,
    this.errorBorderColor,
    this.hintColor,
    this.isObscured = false,
    this.fontSize = 14,
    this.errorText,
    this.controller,
    this.isPassword = false,
    this.enabled,
    this.obscuringCharacter = '*',
    this.fontWeight,
    this.isDense = false,
    this.validator,
    this.formKey,
    this.borderRadius,
    this.maxLines,
    this.initialText,
    this.prefixIcon,
    this.isHasSpecialCharcters = false,
    this.currentFocus,
    this.nextFocus,
    this.isOptional = false,
    this.sourcePrefixImage,
    this.sourceSuffixImage,
    this.trimOnChange = false,
    this.border,
    this.enabledBorder,
    this.height,
    this.disabledBorder,
    this.focusedErrorBorder,
    this.errorBorder,
  });

  @override
  State<PTextField> createState() => _PTextFieldState();
}

class _PTextFieldState extends State<PTextField> {
  TextEditingController? controller;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    controller ??= TextEditingController()..text = widget.initialText ?? '';
    super.initState();
  }

  late bool isObscured = widget.isPassword;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.labelAbove != null
            ? Row(
                children: [
                  PText(
                    title: widget.labelAbove!.tr(),
                    size: widget.labelAboveFontSize ?? PSize.text16,
                    fontColor: widget.labelAboveColor,
                    fontWeight: widget.labelAboveFontWeight ?? FontWeight.w400,
                  ),
                  widget.isFieldRequired
                      ? PText(
                          title: ' *',
                          size: widget.labelAboveFontSize ?? PSize.text16,
                          fontColor: AppColors.errorCode,
                          fontWeight:
                              widget.labelAboveFontWeight ?? FontWeight.w400,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(width: 8),
                  widget.isOptional
                      ? Text(
                          'optional'.tr(),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(),
                        )
                      : Container(),
                ],
              )
            : const SizedBox.shrink(),
        widget.labelAbove != null
            ? const SizedBox(height: 16)
            : const SizedBox.shrink(),
        SizedBox(
          height: widget.height,
          child: Form(
            key: widget.formKey,
            child: TextFormField(
              textAlign: AppLocalization.isArabic
                  ? TextAlign.right
                  : TextAlign.left,

              style: TextStyle(
                fontWeight: widget.fontWeight,
                fontSize: widget.fontSize,
              ),
              enabled: widget.enabled,
              focusNode: widget.currentFocus,
              textInputAction:
                  widget.textInputAction ??
                  (widget.nextFocus != null
                      ? TextInputAction.next
                      : TextInputAction.done),
              scrollController: scrollController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: widget.controller ?? controller,
              obscureText: isObscured,
              cursorColor: AppColors.primaryColor,
              keyboardType: widget.textInputType ?? TextInputType.text,
              inputFormatters: widget.inputFormatters ?? [],
              obscuringCharacter: widget.obscuringCharacter ?? '*',
              maxLines: !isObscured ? widget.maxLines : 1,
              onChanged: (value) {
                String newValue = value;

                if (widget.trimOnChange) {
                  final trimmed = value.trim();
                  if (trimmed != value) {
                    final effectiveController =
                        widget.controller ?? controller!;
                    effectiveController.value = effectiveController.value
                        .copyWith(
                          text: trimmed,
                          selection: TextSelection.collapsed(
                            offset: trimmed.length,
                          ),
                        );
                    newValue = trimmed;
                  }
                }
                if (widget.feedback != null) {
                  widget.feedback!(newValue);
                }
              },

              validator: (value) {
                final v = widget.trimOnChange ? value?.trim() : value;
                return widget.validator?.call(v);
              },

              textDirection:
                  (widget.isHasSpecialCharcters && AppLocalization.isArabic)
                  ? TextDirection.ltr
                  : AppLocalization.isArabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              decoration: InputDecoration(
                label: widget.labelInside == null
                    ? null
                    : PText(title: widget.labelInside!.tr()),
                errorStyle: const TextStyle(color: AppColors.errorBorderColor),
                isDense: widget.isDense ?? false,
                alignLabelWithHint: true,
                hintText: widget.hintText?.tr(),

                contentPadding:
                    widget.contentPadding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: isObscured
                            ? const Icon(Icons.remove_red_eye_outlined)
                            : const Icon(Icons.remove_red_eye),
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                      )
                    : widget.suffixIcon ??
                          (widget.sourceSuffixImage == null
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.all(
                                    12.0,
                                  ), // Adjust padding as needed
                                  child: PImage(
                                    source: widget.sourceSuffixImage!,
                                    width: 24,
                                    height: 24,
                                    color: widget.sourceSuffixImageColor,
                                    fit: BoxFit.contain,
                                  ),
                                )),
                prefixIcon:
                    widget.prefixIcon ??
                    (widget.sourcePrefixImage == null
                        ? null
                        : Padding(
                            padding: const EdgeInsets.all(
                              12.0,
                            ), // Adjust padding as needed
                            child: PImage(
                              source: widget.sourcePrefixImage!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          )),
                filled: true,
                fillColor: widget.fillColor,
                hintStyle: TextStyle(
                  color: widget.hintColor ?? AppColors.contentColor,
                ),
                focusedBorder:
                    widget.focusInputBorder ??
                    OutlineInputBorder(
                      borderSide: BorderSide(
                        width: .5,
                        color:
                            widget.focusedColor ?? AppColors.focusedBorderColor,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 8),
                      ),
                    ),
                errorBorder:
                    widget.errorBorder ??
                    OutlineInputBorder(
                      borderSide: BorderSide(
                        width: .5,
                        color:
                            widget.errorBorderColor ??
                            AppColors.errorBorderColor,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 8),
                      ),
                    ),
                focusedErrorBorder:
                    widget.focusedErrorBorder ??
                    OutlineInputBorder(
                      borderSide: BorderSide(
                        width: .5,
                        color:
                            widget.errorBorderColor ??
                            AppColors.errorBorderColor,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 8),
                      ),
                    ),
                enabledBorder:
                    widget.enabledBorder ??
                    OutlineInputBorder(
                      borderSide: BorderSide(
                        width: .5,
                        color:
                            widget.borderColor ??
                            Theme.of(context)
                                .inputDecorationTheme
                                .border!
                                .borderSide
                                .color,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 8),
                      ),
                    ),
                disabledBorder:
                    widget.disabledBorder ??
                    OutlineInputBorder(
                      borderSide: BorderSide(
                        width: .5,
                        color:
                            widget.disabledBorderColor ?? AppColors.borderColor,
                      ),
                    ),
                border:
                    widget.border ??
                    OutlineInputBorder(
                      borderSide: BorderSide(
                        width: .5,
                        color:
                            widget.borderColor ??
                            Theme.of(context)
                                .inputDecorationTheme
                                .border!
                                .borderSide
                                .color,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.borderRadius ?? 8),
                      ),
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
