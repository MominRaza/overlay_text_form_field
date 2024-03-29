library overlay_text_form_field;

import 'package:flutter/material.dart';

/// A type representing the function passed to [OverlayTextFormField] for its
/// `overlayMentionBuilder` and `overlayTagBuilder`.
typedef OverlayBuilder = Widget Function(
  String query,
  void Function(String selectedValue) onOverlaySelect,
);

/// OverlayTextFormField create a [TextFormField] with ability to show overlay
/// for user mention or tag
class OverlayTextFormField extends StatefulWidget {
  const OverlayTextFormField({
    super.key,
    required this.controller,
    required this.overlayMentionBuilder,
    required this.overlayTagBuilder,
    this.overlayAboveTextField = false,
    this.showMentionOverlay = true,
    this.showTagOverlay = true,
    this.autofocus,
    this.decoration,
    this.textInputAction,
    this.keyboardType,
    this.textCapitalization,
    this.validator,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.onFieldSubmitted,
    this.focusNode,
    this.buildCounter,
    this.contentInsertionConfiguration,
  });

  final TextEditingController controller;

  /// `overlayMentionBuilder` example
  /// ``` dart
  /// final users = [
  ///   {
  ///     'name': 'Momin Raza',
  ///     'handle': 'momin',
  ///   },
  ///   {
  ///     'name': 'Zaid Raza',
  ///     'handle': 'zaid',
  ///   },
  ///   {
  ///     'name': 'Mohd Uzam',
  ///     'handle': 'uzam',
  ///   },
  ///   {
  ///     'name': 'Hammad Raza',
  ///     'handle': 'hammad',
  ///   },
  /// ];
  ///
  /// Widget overlayMentionBuilder(query, onOverlaySelect) {
  ///   return ListView.builder(
  ///     padding: EdgeInsets.zero,
  ///     itemBuilder: (context, index) {
  ///       return (users[index]['handle'] as String).toLowerCase().contains(query)
  ///           ? ListTile(
  ///               visualDensity: VisualDensity.compact,
  ///               leading: const CircleAvatar(),
  ///               title: Text(users[index]['name'] ?? ''),
  ///               subtitle: Text('@${users[index]['handle']}'),
  ///               onTap: () => onOverlaySelect(users[index]['handle']),
  ///             )
  ///           : const SizedBox();
  ///     },
  ///     itemCount: users.length,
  ///   );
  /// }
  /// ```
  final OverlayBuilder overlayMentionBuilder;

  /// `overlayTagBuilder` example
  /// ```dart
  /// final tags = [
  ///   'Superman',
  ///   'Batman',
  ///   'WonderWoman',
  ///   'Aquaman',
  ///   'Cyborg',
  ///   'TheFlash'
  /// ];
  ///
  /// Widget overlayTagBuilder(query, onOverlaySelect) {
  ///   return ListView.builder(
  ///     padding: EdgeInsets.zero,
  ///     itemBuilder: (context, index) {
  ///       return (tags[index]).toLowerCase().contains(query)
  ///           ? ListTile(
  ///               visualDensity: VisualDensity.compact,
  ///               title: Text('#${tags[index]}'),
  ///               onTap: () => onOverlaySelect(tags[index]),
  ///             )
  ///           : const SizedBox();
  ///     },
  ///     itemCount: tags.length,
  ///   );
  /// }
  /// ```
  final OverlayBuilder overlayTagBuilder;

  /// Show overlay above in case using [OverlayTextFormField] in bottomNavigationBar
  final bool overlayAboveTextField;

  /// If `showMentionOverlay: true` then [overlayMentionBuilder] is required
  final bool showMentionOverlay;

  /// If `showTagOverlay: true` then [overlayTagBuilder] is required
  final bool showTagOverlay;

  final bool? autofocus;
  final InputDecoration? decoration;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  final String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final InputCounterWidgetBuilder? buildCounter;
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  @override
  State<OverlayTextFormField> createState() => _OverlayTextFormFieldState();
}

class _OverlayTextFormFieldState extends State<OverlayTextFormField> {
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;
  final _layerLink = LayerLink();

  var _start = '';
  var _query = '';
  var _last = '';

  /// Shows the overlay
  void _showOverlay(bool isMention, bool isTag) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => BackButtonListener(
        onBackButtonPressed: () async {
          _hideOverlay();
          return true;
        },
        child: Positioned(
          width: size.width,
          height: 224,
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, widget.overlayAboveTextField ? -8 : 8),
            targetAnchor: widget.overlayAboveTextField
                ? Alignment.topLeft
                : Alignment.bottomLeft,
            followerAnchor: widget.overlayAboveTextField
                ? Alignment.bottomLeft
                : Alignment.topLeft,
            child: Card(
              clipBehavior: Clip.hardEdge,
              child: isMention
                  ? widget.overlayMentionBuilder(
                      _query.toLowerCase(),
                      _onOverlaySelect,
                    )
                  : isTag
                      ? widget.overlayTagBuilder(
                          _query.toLowerCase(),
                          _onOverlaySelect,
                        )
                      : null,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOverlayVisible = true;
    });
  }

  /// Update the [TextEditingController] with the selected handle or tag and
  /// hides the overlay
  void _onOverlaySelect(String handle) {
    widget.controller.text = '$_start$handle $_last';
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _start.length + handle.length + 1),
    );

    _hideOverlay();
  }

  /// Hides the overlay
  void _hideOverlay() {
    _overlayEntry?.remove();
    setState(() {
      _isOverlayVisible = false;
    });
  }

  /// Checks if text contains any trigger
  void _onChanged() {
    final value = widget.controller.text;
    final cursorPosition = widget.controller.selection.baseOffset;

    final triggervalue = value.substring(0, cursorPosition);

    var match = false;
    var isMention = false;
    var isTag = false;

    if (widget.showMentionOverlay &&
        RegExp(r"(?<!\S)@(\S+)?(?<!\s)$").hasMatch(triggervalue)) {
      isMention = true;
      match = true;
    }
    if (widget.showTagOverlay &&
        RegExp(r"(?<!\S)#(\S+)?(?<!\s)$").hasMatch(triggervalue)) {
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

      _start = triggervalue.substring(0, startindex);
      _query = value.substring(startindex, lastindex > 0 ? lastindex : null);
      _last = lastindex > 0 ? value.substring(lastindex).trimLeft() : '';

      if (_isOverlayVisible) {
        _overlayEntry?.remove();
      }

      _showOverlay(isMention, isTag);
    } else if (!match && _isOverlayVisible) {
      _hideOverlay();
    }
  }

  @override
  void dispose() {
    if (_isOverlayVisible == true) {
      _overlayEntry?.remove();
    }
    _overlayEntry?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        onChanged: (_) => _onChanged(),
        onTap: _onChanged,
        autofocus: widget.autofocus ?? false,
        decoration: widget.decoration,
        textInputAction: widget.textInputAction,
        keyboardType: widget.keyboardType,
        textCapitalization:
            widget.textCapitalization ?? TextCapitalization.none,
        validator: widget.validator,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        onFieldSubmitted: widget.onFieldSubmitted,
        focusNode: widget.focusNode,
        buildCounter: widget.buildCounter,
        contentInsertionConfiguration: widget.contentInsertionConfiguration,
      ),
    );
  }
}
