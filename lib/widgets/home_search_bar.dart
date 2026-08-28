import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final bool isListening;
  final AnimationController? animationController;
  final VoidCallback onListen;
  final bool isDarkMode;
  final Color textColor;
  final Color hintColor;

  const HomeSearchBar({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.onClear,
    required this.isListening,
    required this.animationController,
    required this.onListen,
    required this.isDarkMode,
    required this.textColor,
    required this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode
          ? const Color(0xFF1E1E1E)
          : const Color.fromARGB(255, 210, 22, 239),
      padding: const EdgeInsets.only(left: 16, right: 8, bottom: 16, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color.fromARGB(255, 9, 0, 0)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onChanged,
                style: TextStyle(color: textColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Khapa bie na charô kho?",
                  hintStyle: TextStyle(color: hintColor),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 103, 30, 41),
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: onClear,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              if (isListening && animationController != null)
                AnimatedBuilder(
                  animation: animationController!,
                  builder: (context, child) {
                    return Container(
                      width: 32 + (28 * animationController!.value),
                      height: 32 + (28 * animationController!.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(
                          alpha: 0.4 * (1 - animationController!.value),
                        ),
                      ),
                    );
                  },
                ),
              IconButton(
                icon: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  color: isListening ? Colors.redAccent : Colors.white,
                  size: 28,
                ),
                onPressed: onListen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
