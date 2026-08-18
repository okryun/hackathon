import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../utils/route_names.dart';

import '../../widgets/bottom_nav_bar.dart';

import '../ar/ar_tab_screen.dart';

import '../explore/explore_screen.dart';

import '../my_page/my_page_screen.dart';

import '../saved/saved_screen.dart';

import 'home_screen.dart';

/// Bottom Navigation을 갖는 앱의 최상위 셸.

/// Home / Explore / AR / Saved / My 5개 탭을 IndexedStack으로 관리한다.

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  String? _exploreInitialCategory;

  void _goToProductDetail(String productId) {
    context.push(
      RouteNames.productDetailPath(productId),
    );
  }

  void _goToExploreTab({String? category}) {
    setState(() {
      _currentIndex = 1;

      _exploreInitialCategory = category;
    });
  }

  void _goToSavedTab() {
    setState(() {
      _currentIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onProductTap: _goToProductDetail,
        onSearchTap: () => _goToExploreTab(),
        onCategoryTap: (category) {
          _goToExploreTab(category: category);
        },
      ),

      ExploreScreen(
        onProductTap: _goToProductDetail,
        initialCategory: _exploreInitialCategory,
      ),

      ArTabScreen(
        onProductTap: _goToProductDetail,
        onExploreTap: () => _goToExploreTab(),
      ),

      SavedScreen(
        onProductTap: _goToProductDetail,
        onExploreTap: () => _goToExploreTab(),
      ),

      // MY 페이지

      MyPageScreen(
        onSavedTap: _goToSavedTab,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;

            // Explore 탭을 직접 누르면

            // 이전 카테고리 필터 초기화

            if (index == 1) {
              _exploreInitialCategory = null;
            }
          });
        },
      ),
    );
  }
}
