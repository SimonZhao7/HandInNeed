import 'package:flutter/material.dart';

extension AnimatedNavigation on NavigatorState {
  Future<T?> pushSlideRoute<T>(Widget view) {
    return push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => view,
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          const begin = Offset(1, 0);
          final tween = Tween<Offset>(begin: begin, end: Offset.zero);
          final animationCurve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuint,
            reverseCurve: Curves.easeInQuart,
          );
          return SlideTransition(
            position: animationCurve.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}
