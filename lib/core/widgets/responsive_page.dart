import 'package:flutter/material.dart';
import 'package:motionfit_squat/app/theme/motionfit_tokens.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    required this.child,
    this.maxWidth = 720,
    this.padding,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding:
              padding ??
              EdgeInsetsDirectional.fromSTEB(
                20,
                context.tokens.spaceSm,
                20,
                context.tokens.spaceXl,
              ),
          child: child,
        ),
      ),
    );
  }
}
