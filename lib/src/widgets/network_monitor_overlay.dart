import 'package:flutter/material.dart';

import '../network_monitoring.dart';
import '../models/network_monitor_change.dart';
import '../views/network_monitor_view.dart';
import 'network_monitoring_builder.dart';

/// Manages the draggable floating monitor button overlay entry.
class NetworkMonitorOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static bool get isShowing => _isShowing;

  static void show(BuildContext context) {
    if (_isShowing) return;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => const _FloatingButton(),
    );
    overlay.insert(_overlayEntry!);
    _isShowing = true;
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowing = false;
  }
}

class _FloatingButton extends StatefulWidget {
  const _FloatingButton();

  @override
  State<_FloatingButton> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<_FloatingButton>
    with NetworkMonitorControllerListener {
  @override
  Set<NetworkMonitorChange> get networkMonitorListenTo =>
      NetworkMonitorChanges.floatingButton;

  double _xPosition = 20;  double _yPosition = 200;
  Offset _totalDragOffset = Offset.zero;

  void _openMonitorView() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NetworkMonitorView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = networkMonitorController;
    final screenSize = MediaQuery.of(context).size;
    final recordCount = controller.records.length;
    final hasPausedRequests = controller.activeBreakpointCount > 0;

    _xPosition = _xPosition.clamp(0, screenSize.width - 56);
    _yPosition = _yPosition.clamp(0, screenSize.height - 56);

    return Positioned(
      left: _xPosition,
      top: _yPosition,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onPanStart: (_) {
              _totalDragOffset = Offset.zero;
            },
            onPanUpdate: (details) {
              _totalDragOffset += details.delta;
              setState(() {
                _xPosition += details.delta.dx;
                _yPosition += details.delta.dy;
                _xPosition = _xPosition.clamp(0, screenSize.width - 56);
                _yPosition = _yPosition.clamp(0, screenSize.height - 56);
              });
            },
            onPanEnd: (_) {
              final totalDistance = _totalDragOffset.distance;
              if (totalDistance < 5) {
                _openMonitorView();
              } else {
                setState(() {
                  if (_xPosition > screenSize.width / 2 - 28) {
                    _xPosition = screenSize.width - 60;
                  } else {
                    _xPosition = 4;
                  }
                });
              }
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(28),
              color: Colors.transparent,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasPausedRequests
                        ? [Colors.orange, Colors.deepOrange]
                        : [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (hasPausedRequests ? Colors.orange : Colors.blue)
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      hasPausedRequests
                          ? Icons.pause_circle_filled
                          : Icons.http_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    if (recordCount > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            recordCount > 99 ? '99+' : '$recordCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -6,
            left: -6,
            child: GestureDetector(
              onTap: () {
                NetworkMonitoring.instance.controller.setOverlayVisible(false);
                NetworkMonitorOverlay.hide();
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
