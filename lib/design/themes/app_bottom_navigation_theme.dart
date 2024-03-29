import 'package:flutter/material.dart';
import 'package:hypha_wallet/design/hypha_colors.dart';

class AppBottomNavigationTheme {
  static BottomNavigationBarThemeData bottomNavigationThemeData(
    ColorScheme colorScheme,
    // MindsetTextTheme mindsetTextTheme,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.onPrimary,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: HyphaColors.lightBlue,
      unselectedItemColor: HyphaColors.midGrey,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      type: BottomNavigationBarType.fixed,
      // selectedLabelStyle: mindsetTextTheme.tiny,
      // unselectedLabelStyle: mindsetTextTheme.tiny,
    );
  }
}
