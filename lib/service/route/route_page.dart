import 'package:get/get.dart';
import 'package:mmp_official/screens/auth/login/ui/login_screen.dart';
import 'package:mmp_official/screens/dashboard/ui/dashboard_screen.dart';
import 'package:mmp_official/screens/home/ui/home_screen.dart';
import 'package:mmp_official/screens/members/ui/members_screen.dart';
import 'package:mmp_official/screens/register/ui/register_screen.dart';
import 'package:mmp_official/screens/splash/ui/splash_screen.dart';
import '../../screens/about/ui/about_screen.dart';
import '../../screens/contact/ui/contact_screen.dart';
import '../../screens/events/ui/events_screen.dart';
import '../../screens/gallery/ui/gallery_screen.dart';
import '../../screens/mmpct/ui/mmpct_screen.dart';
import '../../screens/team/ui/team_screen.dart';
import '../../screens/member_registration/ui/member_registration_screen.dart';
import '../../screens/news/ui/news_screen.dart';
import '../../screens/profile/ui/profile_screen.dart';
import 'route_name.dart';

class RoutePage {
  static final routes = [
    GetPage(
      name: RouteName.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: RouteName.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: RouteName.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: RouteName.dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: RouteName.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: RouteName.members,
      page: () => const MembersScreen(),
    ),
    GetPage(
      name: RouteName.memberRegistration,
      page: () => const MemberRegistrationScreen(),
    ),
    GetPage(
      name: RouteName.mmpct,
      page: () => const MMPCTScreen(),
    ),
    GetPage(
      name: RouteName.team,
      page: () => const TeamScreen(),
    ),
    GetPage(
      name: RouteName.about,
      page: () => const AboutScreen(),
    ),
    GetPage(
      name: RouteName.profile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: RouteName.news,
      page: () => const NewsScreen(),
    ),
    GetPage(
      name: RouteName.contact,
      page: () => const ContactScreen(),
    ),
    GetPage(
      name: RouteName.gallery,
      page: () => const GalleryScreen(),
    ),
    GetPage(
      name: RouteName.events,
      page: () => const EventsScreen(),
    ),
  ];
}
