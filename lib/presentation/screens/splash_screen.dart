import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/splash_provider.dart';
import '../widgets/update_popup.dart';
import '../widgets/download_game_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  bool _isNavigationTriggered = false;

  @override
  void initState() {
    super.initState();
    _configureSystemUI();
    _buildAnimationTimelines();
  }

  void _configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  void _buildAnimationTimelines() {
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_logoController);

    _logoController.forward().then((_) {
      context.read<SplashProvider>().initSplashLogic();
    });
  }

  // Navigation Logic unchanged
  void _handleNavigationState(AppTargetScreen state, SplashProvider provider) async {
    if (_isNavigationTriggered) return;
    if (state == AppTargetScreen.showDialog) {
      _isNavigationTriggered = true; 
      _triggerUpdateSequence(provider);
    } else if (state == AppTargetScreen.register) {
      _isNavigationTriggered = true;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreenStub()));
    } else if (state == AppTargetScreen.home) {
      _isNavigationTriggered = true;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreenStub()));
    }
  }

  void _triggerUpdateSequence(SplashProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdatePopup(
        onUpdatePressed: () async {
          Navigator.pop(context);
          bool permitted = await provider.checkInstallPermission();
          if (permitted) _openGameDownloadInterface(provider); else openAppSettings();
        },
      ),
    );
  }

  void _openGameDownloadInterface(SplashProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadGameDialog(
        onDismissFallback: () => provider.evaluateNavigation(),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetState = context.select((SplashProvider p) => p.targetScreen);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigationState(targetState, context.read<SplashProvider>());
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _logoScale,
          child: FadeTransition(
            opacity: _logoOpacity,
            // यहाँ हमने इमेज की जगह एक सिंपल आइकॉन लगा दिया है
            child: const Icon(Icons.gamepad_rounded, size: 100, color: Colors.deepPurple),
          ),
        ),
      ),
    );
  }
}

// Stubs remain the same...
class RegisterScreenStub extends StatelessWidget {
  const RegisterScreenStub({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Register Screen")));
}

class HomeScreenStub extends StatelessWidget {
  const HomeScreenStub({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text("Home Screen")));
}
