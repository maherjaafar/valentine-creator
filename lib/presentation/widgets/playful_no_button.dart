import 'dart:math';

import 'package:flutter/material.dart';

class NoButtonVariant {
  const NoButtonVariant({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class PlayfulNoButtonController {
  void Function(Offset position)? _onCursorMove;

  void _attach(void Function(Offset position) handler) {
    _onCursorMove = handler;
  }

  void _detach() {
    _onCursorMove = null;
  }

  void updateCursor(Offset position) {
    _onCursorMove?.call(position);
  }
}

class PlayfulNoButton extends StatefulWidget {
  const PlayfulNoButton({
    super.key,
    required this.bounds,
    required this.onMessageChanged,
    this.controller,
  });

  final Size bounds;
  final ValueChanged<String> onMessageChanged;
  final PlayfulNoButtonController? controller;

  @override
  State<PlayfulNoButton> createState() => _PlayfulNoButtonState();
}

class _PlayfulNoButtonState extends State<PlayfulNoButton> with SingleTickerProviderStateMixin {
  static const Size _buttonSize = Size(150, 48);
  static const double _detectionRadius = 200.0; // Distance at which button starts escaping
  static const double _minMoveFraction = 0.5;
  static const double _minMovePixels = 180.0;
  static const List<String> _messages = [
    'Oops! The button escaped!',
    'Nice try! It\'s playing hard to get.',
    'The button is allergic to your cursor!',
    'Denied! The button turned into a rocket.',
    'Catch me if you can!',
    'The button prefers YES anyway.',
    'Too slow! Try the YES button instead.',
  ];
  static const List<NoButtonVariant> _variants = [
    NoButtonVariant(label: 'NO', icon: Icons.close_rounded),
  ];

  final Random _random = Random();
  Offset _position = const Offset(180, 12);
  Offset? _lastCursorPosition;
  int _attempts = 0;
  int _variantIndex = 0;
  double _scale = 1.0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(checkCursorProximity);
    // Add a pulsing animation to make it more obvious
    _pulseController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)
      ..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayfulNoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _position = _clampPosition(_position);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(checkCursorProximity);
    }
  }

  void checkCursorProximity(Offset cursorPosition) {
    _lastCursorPosition = cursorPosition;

    final buttonCenter = Offset(
      _position.dx + _buttonSize.width / 2,
      _position.dy + _buttonSize.height / 2,
    );

    final dx = buttonCenter.dx - cursorPosition.dx;
    final dy = buttonCenter.dy - cursorPosition.dy;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance < _detectionRadius) {
      _registerAttempt();
    }
  }

  void _registerAttempt({bool move = true}) {
    setState(() {
      _attempts += 1;
      _variantIndex = _attempts % _variants.length;
      _scale = 0.8; // Shrink on escape
      if (move) {
        _position = _smartEvasion();
      }
    });
    widget.onMessageChanged(_messages[min(_attempts - 1, _messages.length - 1)]);

    // Reset scale after animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _scale = 1.0);
      }
    });
  }

  Offset _smartEvasion() {
    final maxX = max(0.0, widget.bounds.width - _buttonSize.width);
    final maxY = max(0.0, widget.bounds.height - _buttonSize.height);

    if (_lastCursorPosition != null) {
      final buttonCenter = Offset(
        _position.dx + _buttonSize.width / 2,
        _position.dy + _buttonSize.height / 2,
      );

      final candidates = [
        Offset(0.0, 0.0),
        Offset(maxX, 0.0),
        Offset(0.0, maxY),
        Offset(maxX, maxY),
        Offset(maxX * 0.5, 0.0),
        Offset(maxX * 0.5, maxY),
      ];

      Offset farthest = candidates.first;
      double farthestDistance = 0;

      for (final candidate in candidates) {
        final center = Offset(
          candidate.dx + _buttonSize.width / 2,
          candidate.dy + _buttonSize.height / 2,
        );
        final dx = center.dx - _lastCursorPosition!.dx;
        final dy = center.dy - _lastCursorPosition!.dy;
        final distance = sqrt(dx * dx + dy * dy);
        if (distance > farthestDistance) {
          farthestDistance = distance;
          farthest = candidate;
        }
      }

      // Calculate direction away from cursor
      final dx = buttonCenter.dx - _lastCursorPosition!.dx;
      final dy = buttonCenter.dy - _lastCursorPosition!.dy;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance > 0) {
        // Move FAR away in opposite direction
        final angle = atan2(dy, dx) + (_random.nextDouble() - 0.5) * 0.3;

        // Move at least 60% of the available space away
        final minMoveDistance = max(widget.bounds.width, widget.bounds.height) * 0.6;
        final moveDistance = minMoveDistance + _random.nextDouble() * minMoveDistance * 0.4;

        final newX = buttonCenter.dx + cos(angle) * moveDistance - _buttonSize.width / 2;
        final newY = buttonCenter.dy + sin(angle) * moveDistance - _buttonSize.height / 2;

        final attempted = _ensureMinMove(_clampPosition(Offset(newX, newY)));
        // If the attempted move still lands too close, jump to farthest corner.
        if (_distanceToCursor(attempted) < _detectionRadius * 0.9) {
          return _ensureMinMove(farthest);
        }
        return attempted;
      }
    }

    // Fallback: move to opposite corner
    final currentCenterX = _position.dx + _buttonSize.width / 2;
    final currentCenterY = _position.dy + _buttonSize.height / 2;

    final isLeftSide = currentCenterX < widget.bounds.width / 2;
    final isTopSide = currentCenterY < widget.bounds.height / 2;

    final newX = (isLeftSide ? maxX * 0.8 : 0.0) + _random.nextDouble() * maxX * 0.15;
    final newY = (isTopSide ? maxY * 0.8 : 0.0) + _random.nextDouble() * maxY * 0.15;

    return _ensureMinMove(Offset(newX, newY));
  }

  double _distanceToCursor(Offset candidate) {
    if (_lastCursorPosition == null) {
      return double.infinity;
    }
    final center = Offset(
      candidate.dx + _buttonSize.width / 2,
      candidate.dy + _buttonSize.height / 2,
    );
    final dx = center.dx - _lastCursorPosition!.dx;
    final dy = center.dy - _lastCursorPosition!.dy;
    return sqrt(dx * dx + dy * dy);
  }

  Offset _ensureMinMove(Offset target) {
    final current = _position;
    final dx = target.dx - current.dx;
    final dy = target.dy - current.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final minDistance = max(
      _minMovePixels,
      min(widget.bounds.width, widget.bounds.height) * _minMoveFraction,
    );

    if (distance >= minDistance) {
      return _clampPosition(target);
    }

    final angle = distance > 0 ? atan2(dy, dx) : _random.nextDouble() * pi * 2;
    final adjustedX = current.dx + cos(angle) * minDistance;
    final adjustedY = current.dy + sin(angle) * minDistance;
    return _clampPosition(Offset(adjustedX, adjustedY));
  }

  Offset _clampPosition(Offset current) {
    final maxX = max(0.0, widget.bounds.width - _buttonSize.width);
    final maxY = max(0.0, widget.bounds.height - _buttonSize.height);
    return Offset(current.dx.clamp(0.0, maxX), current.dy.clamp(0.0, maxY));
  }

  @override
  Widget build(BuildContext context) {
    final variant = _variants[_variantIndex];

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 120), // Even faster movement
      curve: Curves.easeOutQuart,
      left: _position.dx,
      top: _position.dy,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale:
                _scale *
                (_attempts < 3 ? _pulseAnimation.value : 1.0), // Pulse for first 3 attempts
            child: child,
          );
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click, // Make it obvious it's interactive
          onEnter: (_) => _registerAttempt(),
          child: Container(
            width: _buttonSize.width,
            height: _buttonSize.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B81).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: OutlinedButton.icon(
              onPressed: () => _registerAttempt(),
              icon: Icon(variant.icon, size: 18),
              label: Text(variant.label),
            ),
          ),
        ),
      ),
    );
  }
}
