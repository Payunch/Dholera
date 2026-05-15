class AppAssets {
  // Change this value (1..3) to switch branding set, then rebuild.
  static const int activeLogoSet = 1;

  static String get fullLogo => _fullLogoBySet(activeLogoSet);
  static String get halfLogo => _halfLogoBySet(activeLogoSet);
  static String get logo => fullLogo;

  static String _fullLogoBySet(int set) {
    switch (set) {
      case 2:
        return 'assets/images/sub3.png';
      case 3:
        return 'assets/images/sub5.png';
      case 1:
      default:
        return 'assets/images/sub1.png';
    }
  }

  static String _halfLogoBySet(int set) {
    switch (set) {
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
