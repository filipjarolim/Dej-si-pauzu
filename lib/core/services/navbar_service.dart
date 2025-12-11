import 'package:flutter/foundation.dart';

/// Service to control the visibility of the bottom navigation bar.
class NavbarService {
  NavbarService._();
  
  static final NavbarService instance = NavbarService._();

  final ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);

  void hide() {
    if (isVisible.value) {
      isVisible.value = false;
    }
  }

  void show() {
    if (!isVisible.value) {
      isVisible.value = true;
    }
  }

  void toggle() {
    isVisible.value = !isVisible.value;
  }
}
