import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String label;
  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool keyboardEnabled;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.keyboardEnabled = false,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  bool isOpen = false;
  String search = '';

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.selectedValue;
  }

  @override
  void didUpdateWidget(CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update selected value
    if (widget.selectedValue != oldWidget.selectedValue) {
      _controller.text = widget.selectedValue;

      if (widget.selectedValue.isEmpty) {
        _controller.clear();

        setState(() {
          search = '';
          isOpen = false;
        });
      }
    }

    // Reset search when options change
    if (widget.options != oldWidget.options) {
      search = '';
      isOpen = false;

      if (!widget.options.contains(widget.selectedValue)) {
        _controller.clear();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final filteredOptions = widget.options
        .where((item) => item.toLowerCase().contains(search.toLowerCase()))
        .toList();

    final displayOptions = widget.keyboardEnabled && search.isNotEmpty
        ? filteredOptions
        : widget.options;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LABEL
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.secondary,
            ),
          ),

          const SizedBox(height: 4),

          /// DROPDOWN BOX
          InkWell(
            onTap: () {
              setState(() {
                isOpen = !isOpen;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border.all(color: colors.outline),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      //enabled: widget.keyboardEnabled,
                      readOnly: !widget.keyboardEnabled,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Select option',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isOpen = true;
                        });
                      },
                      onChanged: (value) {
                        if (!widget.keyboardEnabled) return;

                        setState(() {
                          search = value;
                          isOpen = true;
                        });
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// OPTIONS
          /// OPTIONS
          if (isOpen)
            Container(
              margin: const EdgeInsets.only(top: 6),
              child: Material(
                color: theme.cardColor,
                //borderRadius: BorderRadius.circular(6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: colors.outline),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: displayOptions.length,
                    itemBuilder: (context, index) {
                      final item = displayOptions[index];

                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          dense: true,
                          title: Text(item),
                          onTap: () {
                            widget.onChanged(item);

                            _controller.text = item;

                            setState(() {
                              search = '';
                              isOpen = false;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          /// NO RESULTS
          if (widget.keyboardEnabled &&
              search.isNotEmpty &&
              filteredOptions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No match found', textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}
