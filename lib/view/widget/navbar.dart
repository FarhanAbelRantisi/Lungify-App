import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A208FF6),
            offset: const Offset(0, -4),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavItem(
            0,
            widget.currentIndex == 0
                ? 'assets/images/icon_home_fill.svg'
                : 'assets/images/icon_home.svg',
          ),
          const SizedBox(width: 42),
          _buildNavItem(1, 'assets/images/icon_article.svg'),
          const SizedBox(width: 42),
          _buildNavItem(2, 'assets/images/icon_healthbot.png', isPng: true),
          const SizedBox(width: 42),
          _buildNavItem(3, 'assets/images/icon_calender.svg'),
          const SizedBox(width: 42),
          _buildNavItem(4, 'assets/images/icon_history.svg'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, {bool isPng = false}) {
    final bool isActive = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child:
                isPng
                    ? Image.asset(iconPath, width: 45, height: 44)
                    : SvgPicture.asset(
                      iconPath,
                      color:
                          index == 2
                              ? null
                              : (isActive
                                  ? const Color(0xFF2EB5FA)
                                  : const Color(0xFF797C7B)),
                    ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2EB5FA) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
