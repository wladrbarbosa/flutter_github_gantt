import 'package:flutter/material.dart';

class FGCTextField extends StatelessWidget {
  final TextEditingController _controller;
  final String _label;
  final bool obscureText;
  final String _hintText;
  final void Function(String)? onChanged;

  const FGCTextField(
    this._controller,
    this._label,
    this._hintText,
    {
      this.obscureText = false,
      super.key,
      this.onChanged,
    }
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextFormField(
        controller: _controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: _hintText,
          label: Text(_label),
        ),
        onChanged: onChanged,
      ),
    );
  }
}