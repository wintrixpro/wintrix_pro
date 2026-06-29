import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import '../providers/splash_provider.dart';

class DownloadGameDialog extends StatefulWidget {
  final VoidCallback onDismissFallback;

  const DownloadGameDialog({Key? key, required this.onDismissFallback}) : super(key: key);

  @override
  State<DownloadGameDialog> createState() => _DownloadGameDialogState();
}

class _DownloadGameDialogState extends State<DownloadGameDialog> with SingleTickerProviderStateMixin {
  int score = 0;
  double shipX = 150.0;
  bool isPressing = false;
  List<Offset> bullets = [];
  List<Offset> enemies = [];
  late AnimationController _gameLoop;
  int frameCount = 0;

  @override
  void initState() {
    super.initState();
    _gameLoop = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _gameLoop.addListener(_runEngine);

    WidgetsBinding.instance.addPostFrameCallback((_) => _executeDownloadSequence());
  }

  void _executeDownloadSequence() async {
    final provider = Provider.of<SplashProvider>(context, listen: false);
    bool downloadSuccess = await provider.startApkDownload();
    
    _gameLoop.stop();
    if (!mounted) return;
    Navigator.pop(context);

    if (downloadSuccess) {
      try {
        await OpenFilex.open(provider.downloadedPath);
        SystemNavigator.pop();
      } catch (_) {
        widget.onDismissFallback();
      }
    } else {
      widget.onDismissFallback();
    }
  }

  void _runEngine() {
    frameCount++;
    final Size canvasSize = const Size(300, 400);

    setState(() {
      if (frameCount % 45 == 0) {
        enemies.add(Offset(30.0 + Random().nextDouble() * (canvasSize.width - 60), 0));
      }
      if (isPressing && frameCount % 8 == 0) {
        bullets.add(Offset(shipX, canvasSize.height - 60));
        HapticFeedback.lightImpact();
      }

      bullets = bullets.where((b) => b.dy - 12 > 0).map((b) => Offset(b.dx, b.dy - 12)).toList();

      List<Offset> currentEnemies = [];
      for (var e in enemies) {
        double nextY = e.dy + 4.0;
        if (nextY < canvasSize.height) {
          bool hit = false;
          for (int i = 0; i < bullets.length; i++) {
            if ((bullets[i] - Offset(e.dx, nextY)).distance < 30.0) {
              bullets.removeAt(i);
              hit = true;
              score += 10;
              HapticFeedback.mediumImpact();
              break;
            }
          }
          if (!hit) currentEnemies.add(Offset(e.dx, nextY));
        }
      }
      enemies = currentEnemies;
    });
  }

  @override
  void dispose() {
    _gameLoop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.select((SplashProvider p) => p.downloadProgress);

    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: 300,
        height: 500,
        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Score: $score", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Updating: $progress%", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            LinearProgressIndicator(value: progress / 100, backgroundColor: Colors.grey[900], color: const Color(0xFF38BDF8)),
            Expanded(
              child: ClipRect(
                child: CustomPaint(
                  painter: _MiniGamePainter(shipX: shipX, bullets: bullets, enemies: enemies),
                  child: Container(),
                ),
              ),
            ),
            GestureDetector(
              onPanDown: (d) => _moveFighter(d.localPosition.dx),
              onPanUpdate: (d) => _moveFighter(d.localPosition.dx),
              onPanEnd: (_) => setState(() => isPressing = false),
              onPanCancel: () => setState(() => isPressing = false),
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                alignment: Alignment.center,
                child: const Text("Hold & Slide to control Fighter Jet", style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w540)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _moveFighter(double x) {
    isPressing = true;
    if (x >= 20 && x <= 280) {
      setState(() => shipX = x);
    }
  }
}

class _MiniGamePainter extends CustomPainter {
  final double shipX;
  final List<Offset> bullets;
  final List<Offset> enemies;

  _MiniGamePainter({required this.shipX, required this.bullets, required this.enemies});

  @override
  void paint(Canvas canvas, Size size) {
    final shipPaint = Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.fill;
    final laserPaint = Paint()..color = const Color(0xFFEF4444)..strokeWidth = 4.0;
    final enemyPaint = Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.fill;

    final jetPath = Path()
      ..moveTo(shipX, size.height - 45)
      ..lineTo(shipX - 22, size.height - 15)
      ..lineTo(shipX + 22, size.height - 15)
      ..close();
    canvas.drawPath(jetPath, shipPaint);

    for (var b in bullets) {
      canvas.drawLine(b, Offset(b.dx, b.dy - 12), laserPaint);
    }
    for (var e in enemies) {
      canvas.drawCircle(e, 14.0, enemyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniGamePainter oldDelegate) => true;
}
