import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late AnimationController _buttonScaleController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _transitionController.value = 1.0; // Start fully visible

    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _buttonScaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  void _onGetStartedPressed() async {
    // 1. Play button press (scale down)
    await _buttonScaleController.forward();
    // 2. Play button release (scale up back to normal) - total button click animation = 400ms
    await _buttonScaleController.reverse();
    // 3. Play page slide and fade transition out
    await _transitionController.reverse();
    // 4. Navigate to Login screen
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading || authState.user != null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
        ),
      );
    }
    final slideAnimation = Tween<Offset>(
      begin: const Offset(-0.08, 0.0), // slides slightly left as it exits
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeIn,
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEBF3EE), // Soft light green
            Color(0xFFFCF5EF), // Soft peach
            Color(0xFFEAF1EC), // Soft green-beige
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: SafeArea(
              child: Stack(
                children: [
                   // Floating decorative leaf top-left
                  Positioned(
                    top: -10,
                    left: -30,
                    child: Opacity(
                      opacity: 0.08,
                      child: Transform.rotate(
                        angle: -0.4,
                        child: const Icon(
                          Icons.eco,
                          size: 160,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),

                  // Floating decorative splash top-right
                  Positioned(
                    top: 60,
                    right: -30,
                    child: Opacity(
                      opacity: 0.08,
                      child: Transform.rotate(
                        angle: 0.8,
                        child: const Icon(
                          Icons.spa,
                          size: 140,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      const SizedBox(height: 36),

                      // Top Title - "Farm Fresh"
                      Text(
                        'Farm Fresh',
                        style: GoogleFonts.outfit(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF23312B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Central Grocery Bag Overflowing with vegetables & Badges
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: const Icon(
                              Icons.shopping_basket_rounded,
                              size: 160,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Bottom Actions Row with smooth click animation
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Row(
                          children: [
                            // Orange Gradient "Get Started" button with scale animation
                            Expanded(
                              child: ScaleTransition(
                                scale: _buttonScale,
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(26),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE28C43),
                                        Color(0xFFC87028),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFE28C43).withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _onGetStartedPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                    ),
                                    child: Text(
                                      'Get Started',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
