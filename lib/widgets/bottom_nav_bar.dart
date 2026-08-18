import 'package:flutter/material.dart';

class NavTabItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const NavTabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

/// Home / Explore / 체크인 / Saved / My 5개 탭의 하단 네비게이션.
/// HomeShell에서 현재 인덱스와 탭 변경 콜백을 주입받아 사용한다.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<NavTabItem> tabs = [
    NavTabItem(label: '홈', icon: Icons.home_outlined, selectedIcon: Icons.home),
    NavTabItem(label: '탐색', icon: Icons.search_outlined, selectedIcon: Icons.search),
    NavTabItem(label: '체크인', icon: Icons.nfc_outlined, selectedIcon: Icons.nfc),
    NavTabItem(label: '저장', icon: Icons.favorite_border, selectedIcon: Icons.favorite),
    NavTabItem(label: '마이', icon: Icons.person_outline, selectedIcon: Icons.person),
  ];

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        for (final tab in tabs)
          BottomNavigationBarItem(
            icon: Icon(tab.icon),
            activeIcon: Icon(tab.selectedIcon),
            label: tab.label,
          ),
      ],
    );
  }
}
