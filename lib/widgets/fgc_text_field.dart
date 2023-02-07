import 'package:flutter/material.dart';

class FGCTextField extends StatelessWidget {
  final TextEditingController _controller;
  final String _label;
  final String _hintText;
  final void Function(String)? onChanged;

  const FGCTextField(
    this._controller,
    this._label,
    this._hintText,
    {
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
        obscureText: true,
        decoration: InputDecoration(
          hintText: _hintText,
          label: Text(_label),
        ),
      ),
    );
  }
}