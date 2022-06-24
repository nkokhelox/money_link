import 'package:flutter/material.dart';

class PortraitOnlyRoute<T> extends MaterialPageRoute<T> {
  PortraitOnlyRoute({required super.builder});

  @override
  Widget buildContent(BuildContext context) {
    final isDualPane = MediaQuery.of(context).size.width > 550;
    if (isDualPane) {
      Future.delayed(const Duration(milliseconds: 100), () {
        navigator?.removeRoute(this);
      });
    }

    return super.buildContent(context);
  }
}
