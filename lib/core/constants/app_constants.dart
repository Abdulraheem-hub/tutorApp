/**
 * @context7:feature:constants
 * @context7:pattern:app_constants
 * 
 * Application-wide constants for TutorPay app
 */

class AppConstants {
  // App Information
  static const String appName = 'TutorPay';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (when implementing real API)
  static const String baseUrl = 'https://api.tutorpay.com';
  
  // Local Storage Keys
  static const String userDataKey = 'user_data';
  static const String themeDataKey = 'theme_data';
  static const String onboardingKey = 'onboarding_completed';
  
  // Dashboard Constants
  static const String currencySymbol = '\$';
  static const int dashboardRefreshInterval = 300; // seconds
  
  // Navigation
  static const int defaultBottomNavIndex = 0;
  
  // Animations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 2);
  
  // Formatting
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
}

class AppRoutes {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String payments = '/payments';
  static const String students = '/students';
  static const String profile = '/profile';
  static const String addPayment = '/add-payment';
  static const String addStudent = '/add-student';
  static const String studentDetail = '/student-detail';
  static const String paymentDetail = '/payment-detail';
}

class AppAssets {
  // Icons (when we add custom icons)
  static const String iconsPath = 'assets/icons/';
  
  // Images
  static const String imagesPath = 'assets/images/';
  
  // Animations (if we add Lottie files)
  static const String animationsPath = 'assets/animations/';
}
