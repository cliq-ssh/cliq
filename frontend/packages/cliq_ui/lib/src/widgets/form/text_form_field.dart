import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart';

class CliqTextFormField extends FormField<String> {
  final TextEditingController? controller;
  final Widget? label;
  final Widget? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscure;
  final int? minLines;
  final int? maxLines;
  final Function(String)? onChanged;
  final CliqTextFieldStyle? style;

  CliqTextFormField({
    super.key,
    super.validator,
    super.autovalidateMode,
    super.errorBuilder = _defaultErrorBuilder,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscure = false,
    this.minLines,
    this.maxLines,
    this.onChanged,
    this.style,
  }) : super(
         builder: (state) {
           return CliqTextField(
             controller: controller,
             label: label,
             hint: hint,
             error: state.hasError && errorBuilder != null
                 ? errorBuilder(state.context, state.errorText!)
                 : null,
             prefixIcon: prefixIcon,
             suffixIcon: suffixIcon,
             obscure: obscure,
             minLines: minLines,
             maxLines: maxLines,
             onChanged: (value) {
               state.didChange(value);
               onChanged?.call(value);
             },
             style: style,
           );
         },
       );

  static Widget _defaultErrorBuilder(BuildContext context, String value) =>
      Text(value);
}
