import 'package:flutter/material.dart';
import 'package:nest_user_app/constants/colors.dart';

class HomePageSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  const HomePageSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Search',
    this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300, width: 3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
