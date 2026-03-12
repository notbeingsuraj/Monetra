class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String lend = '/lend';
  static const String lendRequest = '/lend-request';
  static const String borrow = '/borrow';
  static const String requests = '/requests';
  static const String loanDetail = '/loans/:id';
  static const String profile = '/profile';

  static String loanDetailPath(String id) => '/loans/$id';
}
