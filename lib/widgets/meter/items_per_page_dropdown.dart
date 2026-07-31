import 'package:flutter/material.dart';

class ItemsPerPageDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const ItemsPerPageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Items",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),

        const SizedBox(width: 6),

        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: value,
            borderRadius: BorderRadius.circular(10),
            isDense: true,
            items: const [
              DropdownMenuItem(value: 10, child: Text("10")),
              DropdownMenuItem(value: 20, child: Text("20")),
              DropdownMenuItem(value: 50, child: Text("50")),
              DropdownMenuItem(value: 75, child: Text("75")),
              DropdownMenuItem(value: 100, child: Text("100")),
            ],
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      ],
    );
  }
}
