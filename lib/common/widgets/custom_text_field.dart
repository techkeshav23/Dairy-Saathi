import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saathi/util/app_colors.dart';
import 'package:saathi/util/dimensions.dart';
import 'package:saathi/util/styles.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? prefixText;

  const CustomTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeSmall, color: AppColors.textMedium)),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: robotoRegular.copyWith(
              color: AppColors.textLight, fontSize: Dimensions.fontSizeDefault),
            prefixText: prefixText,
            prefixStyle: robotoMedium.copyWith(
              color: AppColors.textDark, fontSize: Dimensions.fontSizeDefault),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: Dimensions.iconSizeDefault, color: AppColors.textLight)
                : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
