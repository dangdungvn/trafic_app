import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traffic_app/theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscure = true;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _isFocused = _focusNode.hasFocus;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: _isFocused
            ? AppTheme.primaryColor.withOpacity(0.08)
            : AppTheme.inputFillColor,
        borderRadius: BorderRadius.circular(12.r),
        border: _isFocused
            ? Border.all(color: AppTheme.primaryColor, width: 1)
            : null,
      ),
      padding: .symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Icon(
            widget.prefixIcon,
            color: _isFocused ? AppTheme.primaryColor : AppTheme.subTextColor,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.isPassword && _isObscure,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              cursorColor: AppTheme.primaryColor,
              style: GoogleFonts.urbanist(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: GoogleFonts.urbanist(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.subTextColor,
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (widget.isPassword)
            IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility_off : Icons.visibility,
                color: _isFocused
                    ? AppTheme.primaryColor
                    : AppTheme.subTextColor,
                size: 20.sp,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
            ),
        ],
      ),
    );
  }
}
