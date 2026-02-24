import 'package:flutter/material.dart';
import 'package:traffic_app/modules/dashboard/controllers/dashboard_controller.dart';

/// Widget bọc bài viết mới: slide xuống từ trên + fade in khi vừa được đăng
class NewPostAnimator extends StatefulWidget {
  final Widget child;
  final DashboardController dashController;

  const NewPostAnimator({
    super.key,
    required this.child,
    required this.dashController,
  });

  @override
  State<NewPostAnimator> createState() => NewPostAnimatorState();
}

class NewPostAnimatorState extends State<NewPostAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);

    _anim.forward();
    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.dashController.clearNewPostId();
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
