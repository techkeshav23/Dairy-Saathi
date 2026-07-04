import 'package:flutter/material.dart';
import 'package:my_order_pro/util/dimensions.dart';

/// Shared text styles. Uses the default platform font (Roboto on Android) with
/// explicit weights — no runtime font download, so it works fully offline.

const String _fontFamily = 'Roboto';

final TextStyle robotoRegular = TextStyle(
  fontFamily: _fontFamily,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
);

final TextStyle robotoMedium = TextStyle(
  fontFamily: _fontFamily,
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeDefault,
);

final TextStyle robotoSemiBold = TextStyle(
  fontFamily: _fontFamily,
  fontWeight: FontWeight.w600,
  fontSize: Dimensions.fontSizeDefault,
);

final TextStyle robotoBold = TextStyle(
  fontFamily: _fontFamily,
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeDefault,
);

final TextStyle robotoBlack = TextStyle(
  fontFamily: _fontFamily,
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);
