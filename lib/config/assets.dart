class AppAssets {
  // Set this to 1, 2, or 3 to select which main image to use
  static const int activeSet = 1;

  // Paths to the main files
  static const String logoFile = 'assets/images/logo.png';
  
  static String get mainImage => 'assets/images/sub$activeSet.png';

  // "Upper side is full logo, bottom size is only logo"
  // We use these with the DholeraLogo widget to crop dynamically
  static const String fullLogoPath = logoFile;
  static const String iconOnlyLogoPath = logoFile;

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
