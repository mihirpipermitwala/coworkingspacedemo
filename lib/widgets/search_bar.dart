import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  const CustomSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = "Search...",
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      ),
    );
  }
}
