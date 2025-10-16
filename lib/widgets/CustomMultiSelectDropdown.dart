import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomMultiSelectDropdown extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> selectedItems;
  final Function(List<Map<String, dynamic>>) onChanged;
  final bool enabled;
  final String Function(Map<String, dynamic>)?
      itemBuilder; // Custom text builder

  const CustomMultiSelectDropdown({
    Key? key,
    required this.hintText,
    this.prefixIcon,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.enabled = true,
    this.itemBuilder,
  }) : super(key: key);

  @override
  State<CustomMultiSelectDropdown> createState() =>
      _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  // Create a local reactive list to track selections
  late RxList<Map<String, dynamic>> _localSelectedItems;

  @override
  void initState() {
    super.initState();
    // Initialize local reactive list with a copy of widget.selectedItems
    _localSelectedItems =
        RxList<Map<String, dynamic>>(List.from(widget.selectedItems));
  }

  @override
  void didUpdateWidget(CustomMultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync local list with parent if it changes externally
    if (widget.selectedItems != oldWidget.selectedItems) {
      _localSelectedItems.assignAll(widget.selectedItems);
    }
  }

  @override
  void dispose() {
    _closeDropdown();
    _localSelectedItems.close(); // Dispose of the RxList
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!widget.enabled) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 4.0),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 250,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() => widget.items.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'لا توجد فئات متاحة',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final isSelected = _localSelectedItems
                            .any((selected) => selected['id'] == item['id']);

                        // Use custom itemBuilder or default text
                        final displayText = widget.itemBuilder != null
                            ? widget.itemBuilder!(item)
                            : _getDefaultDisplayText(item);

                        return InkWell(
                          onTap: () => _toggleItemSelection(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFEF4444)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF9CA3AF),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    displayText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? const Color(0xFF111827)
                                          : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
            ),
          ),
        ),
      ),
    );
  }

  // Default display text
  String _getDefaultDisplayText(Map<String, dynamic> item) {
    final isArabic = Get.locale?.languageCode == 'ar';
    return isArabic
        ? item['titleAr']?.toString() ??
            item['titleEn']?.toString() ??
            item['name']?.toString() ??
            'غير محدد'
        : item['titleEn']?.toString() ??
            item['titleAr']?.toString() ??
            item['name']?.toString() ??
            'Not specified';
  }

  void _toggleItemSelection(Map<String, dynamic> item) {
    List<Map<String, dynamic>> updatedSelection =
        List.from(_localSelectedItems);

    final index =
        updatedSelection.indexWhere((selected) => selected['id'] == item['id']);

    if (index >= 0) {
      updatedSelection.removeAt(index);
    } else {
      updatedSelection.add(item);
    }

    // Update local reactive list
    _localSelectedItems.assignAll(updatedSelection);
    // Notify parent of the change
    widget.onChanged(updatedSelection);
  }

  String _getSelectedText() {
    if (_localSelectedItems.isEmpty) {
      return widget.hintText;
    } else if (_localSelectedItems.length == 1) {
      final item = _localSelectedItems.first;
      return widget.itemBuilder != null
          ? widget.itemBuilder!(item)
          : _getDefaultDisplayText(item);
    } else {
      final isArabic = Get.locale?.languageCode == 'ar';
      return isArabic
          ? '${_localSelectedItems.length} فئات محددة'
          : '${_localSelectedItems.length} categories selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isOpen
                  ? const Color(0xFFEF4444)
                  : widget.enabled
                      ? const Color(0xFFE5E7EB)
                      : Colors.grey[300]!,
              width: _isOpen ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: Icon(
                    widget.prefixIcon,
                    color: widget.enabled
                        ? const Color(0xFF6B7280)
                        : Colors.grey[400],
                    size: 20,
                  ),
                ),
              ],
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: widget.prefixIcon != null ? 0 : 16,
                    right: 12,
                  ),
                  child: Obx(() => Text(
                        _getSelectedText(),
                        style: TextStyle(
                          fontSize: 16,
                          color: _localSelectedItems.isNotEmpty
                              ? const Color(0xFF111827)
                              : const Color(0xFF9CA3AF),
                          fontWeight: _localSelectedItems.isNotEmpty
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
              ),
              
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: Icon(
                  _isOpen ? Icons.expand_less : Icons.expand_more,
                  color: widget.enabled
                      ? const Color(0xFF6B7280)
                      : Colors.grey[400],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}