import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final bool isListening;
  final AnimationController animationController;
  final VoidCallback onListen;
  final bool isDarkMode;
  final Color headerColor;

  const HomeSearchBar({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.onClear,
    required this.isListening,
    required this.animationController,
    required this.onListen,
    required this.isDarkMode,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    const goldAccent = Color(0xFF9E7A42);

    final searchBoxBg = isDarkMode
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFEFE5CE);
    final inputTextColor = isDarkMode ? Colors.white : const Color(0xFF2C2C2C);
    final hintTextColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF7A6E5D);

    return Container(
      decoration: BoxDecoration(
        // Continues the app bar gradient: starts with the shade where it ended
        gradient: LinearGradient(
          colors: [
            Color.lerp(headerColor, Colors.black, 0.17)!,
            Color.lerp(headerColor, Colors.black, 0.35)!,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 18, top: 2),
      child: Container(
        decoration: BoxDecoration(
          color: searchBoxBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFDFBA7B).withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: onChanged,
          style: TextStyle(
            color: inputTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Khapa bie na charô kho?",
            hintStyle: TextStyle(
              color: hintTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(Icons.search, color: goldAccent, size: 26),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                    onPressed: onClear,
                  ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isListening)
                      AnimatedBuilder(
                        animation: animationController,
                        builder: (context, child) {
                          final v = animationController.value;
                          return Container(
                            width: 28 + (20 * v),
                            height: 28 + (20 * v),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent.withValues(
                                alpha: 0.4 * (1 - v),
                              ),
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: isListening ? Colors.redAccent : goldAccent,
                        size: 26,
                      ),
                      onPressed: onListen,
                    ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
