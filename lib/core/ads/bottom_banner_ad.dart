import 'package:flutter/widgets.dart';
import 'ad_sdk.dart';
import 'ad_slot.dart';

class BottomBannerAd extends StatelessWidget {
  const BottomBannerAd({this.active = true, super.key});
  final bool active;
  @override
  Widget build(BuildContext context) => AdSlot(
    format: AdFormat.banner,
    placement: 'bottom_navigation',
    active: active,
  );
}
