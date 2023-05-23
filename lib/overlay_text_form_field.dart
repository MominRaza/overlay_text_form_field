library overlay_text_form_field;

import 'package:flutter/material.dart';

typedef OverlayBuilder = Widget Function(
  String query,
  void Function(String selectedValue) onOverlaySelect,
);

class OverlayTextFormField extends StatefulWidget {
  const OverlayTextFormField({
    super.key,
    required this.controller,
    this.onFieldSubmitted,
    required this.overlayMentionBuilder,
    required this.overlayTagBuilder,
  });
  final TextEditingController controller;
  final void Function(String)? onFieldSubmitted;

  final OverlayBuilder overlayMentionBuilder;
  final OverlayBuilder overlayTagBuilder;

  @override
  State<OverlayTextFormField> createState() => _OverlayTextFormFieldState();
}

class _OverlayTextFormFieldState extends State<OverlayTextFormField> {
  OverlayEntry? overlayEntry;
  bool isOverlayVisible = false;
  final layerLink = LayerLink();

  var start = '';
  var query = '';
  var last = '';

  showOverlay(bool isMention, bool isTag) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    overlayEntry = OverlayEntry(
      builder: (context) => BackButtonListener(
        onBackButtonPressed: () async {
          hideOverlay();
          return true;
        },
        child: Positioned(
          width: size.width,
          height: 224,
          child: CompositedTransformFollower(
            link: layerLink,
            offset: Offset(0, size.height + 8),
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: isMention
                  ? widget.overlayMentionBuilder(
                      query.toLowerCase(),
                      onOverlaySelect,
                    )
                  : isTag
                      ? widget.overlayTagBuilder(
                          query.toLowerCase(),
                          onOverlaySelect,
                        )
                      : null,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
    setState(() {
      isOverlayVisible = true;
    });
  }

  void onOverlaySelect(String handle) {
    widget.controller.text = '$start$handle $last';
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: start.length + handle.length + 1),
    );
    hideOverlay();
  }

  hideOverlay() {
    overlayEntry?.remove();
    setState(() {
      isOverlayVisible = false;
    });
  }

  onChanged() {
    final value = widget.controller.text;
    final cursorPosition = widget.controller.selection.baseOffset;

    final triggervalue = value.substring(0, cursorPosition);

    var match = false;
    var isMention = false;
    var isTag = false;

    if (RegExp(r"(?<!\S)@(\S+)?(?<!\s)$").hasMatch(triggervalue)) {
      isMention = true;
      match = true;
    }
    if (RegExp(r"(?<!\S)#(\S+)?(?<!\s)$").hasMatch(triggervalue)) {
      isTag = true;
      match = true;
    }

    if (match) {
      final startindex = triggervalue.lastIndexOf(isMention
              ? '@'
              : isTag
                  ? '#'
                  : '') +
          1;
      final lastindex = value.indexOf(' ', cursorPosition);

      start = triggervalue.substring(0, startindex);
      query = value.substring(startindex, lastindex > 0 ? lastindex : null);
      last = lastindex > 0 ? value.substring(lastindex).trimLeft() : '';

      if (isOverlayVisible) {
        overlayEntry?.remove();
      }

      showOverlay(isMention, isTag);
    } else if (!match && isOverlayVisible) {
      hideOverlay();
    }
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    overlayEntry?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: TextFormField(
        controller: widget.controller,
        onChanged: (_) => onChanged(),
        onTap: onChanged,
      ),
    );
  }
}
