class AppAssets {
  // Set this to 1, 2, or 3 to select branding set.
  static const int activeSet = 1;

  static String get fullLogoPath {
    switch (activeSet) {
      case 2:
        return 'assets/images/sub3.png';
      case 3:
        return 'assets/images/sub5.png';
      case 1:
      default:
        return 'assets/images/sub1.png';
    }
  }

  static String get halfLogoPath {
    switch (activeSet) {
      case 2:
        return 'assets/images/sub4.png';
      case 3:
        return 'assets/images/sub6.png';
      case 1:
      default:
        return 'assets/images/sub2.png';
    }
  }

  static const List<String> galleryImages = [
    'assets/images/sub1.png',
    'assets/images/sub2.png',
    'assets/images/sub3.png',
    'assets/images/sub4.png',
    'assets/images/sub5.png',
    'assets/images/sub6.png',
  ];

  static const String appName = 'Dholera Growth Platform';
}
