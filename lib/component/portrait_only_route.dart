import 'package:flutter/material.dart';

class PortraitOnlyRoute<T> extends MaterialPageRoute<T> {
  PortraitOnlyRoute({required super.builder});

  @override
  Widget buildContent(BuildContext context) {
    LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final isDualPane = constraints.maxWidth > 550;
      if (isDualPane) {
        Future.delayed(const Duration(milliseconds: 100), () {
          navigator?.removeRoute(this);
        });
      }

      return super.buildContent(context);
    });
    return super.buildContent(context);
  }
}
