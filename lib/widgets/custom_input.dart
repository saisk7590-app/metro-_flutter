import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool multiline;

  const CustomInput({
    super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 2),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.secondary,
                ),
              ),
            ),

          /// Input Field
          TextField(
            controller: controller,
            maxLines: multiline ? 4 : 1,
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: placeholder,

              filled: true,

              fillColor: colors.surface,

              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 14,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.outline),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
