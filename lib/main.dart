import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/public_news_provider.dart';
import 'providers/public_ad_provider.dart';
import 'screens/home_screen.dart';
import 'screens/news_detail_screen.dart';
import 'screens/category_news_screen.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/news/:slug',
      builder: (context, state) => NewsDetailScreen(slug: state.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) => CategoryNewsScreen(categoryId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PublicNewsProvider()),
        ChangeNotifierProvider(create: (_) => PublicAdProvider()),
      ],
      child: MaterialApp.router(
        title: 'NewsMinute',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: GoogleFonts.merriweatherTextTheme(), // Editorial feel
        ),
        routerConfig: _router,
      ),
    );
  }
}
