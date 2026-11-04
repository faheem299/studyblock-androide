// import 'package:flutter/material.dart';
// import 'home_screen.dart';
// import 'theme.dart';

// const creatorName = 'Faheem Fayaz';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _c = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 2600),
//   );
//   bool _left = false;

//   @override
//   void initState() {
//     super.initState();
//     _c.forward().whenComplete(_goHome);
//   }

//   void _goHome() {
//     if (_left || !mounted) return;
//     _left = true;
//     Navigator.of(context).pushReplacement(PageRouteBuilder(
//       transitionDuration: const Duration(milliseconds: 500),
//       pageBuilder: (_, __, ___) => const HomeScreen(),
//       transitionsBuilder: (_, anim, __, child) =>
//           FadeTransition(opacity: anim, child: child),
//     ));
//   }

//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: C.bg,
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _goHome, // tap to skip
//         child: Center(
//           child: AnimatedBuilder(
//             animation: _c,
//             builder: (context, _) {
//               final t = _c.value;
//               double seg(double a, double b) =>
//                   Curves.easeOutCubic.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

//               final title = seg(0.40, 0.70);
//               final by = seg(0.65, 0.95);

//               return Column(mainAxisSize: MainAxisSize.min, children: [
//                 Row(mainAxisSize: MainAxisSize.min, children: [
//                   for (var i = 0; i < 10; i++)
//                     _block(i, seg(i * 0.04, i * 0.04 + 0.16)),
//                 ]),
//                 const SizedBox(height: 28),
//                 Opacity(
//                   opacity: title,
//                   child: Transform.translate(
//                     offset: Offset(0, 18 * (1 - title)),
//                     child: Text('StudyBlock',
//                         style: syne(36, weight: FontWeight.w800)),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Opacity(
//                   opacity: by,
//                   child: Text('by $creatorName',
//                       style: mono(13, color: C.muted).copyWith(letterSpacing: 2)),
//                 ),
//               ]);
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _block(int i, double p) => Opacity(
//         opacity: p,
//         child: Transform.scale(
//           scale: 0.4 + 0.6 * p,
//           child: Container(
//             width: 16,
//             height: 16,
//             margin: const EdgeInsets.symmetric(horizontal: 3),
//             decoration: BoxDecoration(
//               color: i < 5 ? C.blue : C.green,
//               borderRadius: BorderRadius.zero,
//             ),
//           ),
//         ),
//       );
// }




// import 'package:flutter/material.dart';
// import 'home_screen.dart';
// import 'theme.dart';

// const creatorName = 'Faheem Fayaz';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _c = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 3200),
//   );
//   bool _left = false;

//   static const _title = 'StudyBlock';

//   @override
//   void initState() {
//     super.initState();
//     _c.forward().whenComplete(_goHome);
//   }

//   void _goHome() {
//     if (_left || !mounted) return;
//     _left = true;
//     Navigator.of(context).pushReplacement(PageRouteBuilder(
//       transitionDuration: const Duration(milliseconds: 900),
//       pageBuilder: (_, __, ___) => const HomeScreen(),
//       transitionsBuilder: (_, anim, __, child) =>
//           FadeTransition(opacity: anim, child: child),
//     ));
//   }

//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: C.bg,
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _goHome, // tap to skip
//         child: Center(
//           child: AnimatedBuilder(
//             animation: _c,
//             builder: (context, _) {
//               final t = _c.value;

//               double seg(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
//                   curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

//               final by = seg(0.85, 1.0);

//               return Column(mainAxisSize: MainAxisSize.min, children: [
//                 // Blocks: drop + bounce, then blue -> green color sweep
//                 Row(mainAxisSize: MainAxisSize.min, children: [
//                   for (var i = 0; i < 10; i++)
//                     _block(
//                       drop: seg(i * 0.04, i * 0.04 + 0.30, Curves.bounceOut),
//                       sweep: seg(0.50 + i * 0.03, 0.62 + i * 0.03,
//                           Curves.easeInOut),
//                     ),
//                 ]),
//                 const SizedBox(height: 28),

//                 // Title: letters slide up one by one
//                 Row(mainAxisSize: MainAxisSize.min, children: [
//                   for (var i = 0; i < _title.length; i++)
//                     _letter(
//                       _title[i],
//                       seg(0.60 + i * 0.025, 0.60 + i * 0.025 + 0.15),
//                     ),
//                 ]),
//                 const SizedBox(height: 10),

//                 Opacity(
//                   opacity: by,
//                   child: Text('by $creatorName',
//                       style: mono(13, color: C.muted)
//                           .copyWith(letterSpacing: 2 + 2 * (1 - by))),
//                 ),
//               ]);
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _block({required double drop, required double sweep}) => Opacity(
//         opacity: (drop * 4).clamp(0.0, 1.0),
//         child: Transform.translate(
//           offset: Offset(0, -280 * (1 - drop)),
//           child: Container(
//             width: 16,
//             height: 16,
//             margin: const EdgeInsets.symmetric(horizontal: 3),
//             decoration: BoxDecoration(
//               color: Color.lerp(C.blue, C.green, sweep),
//               borderRadius: BorderRadius.zero,
//             ),
//           ),
//         ),
//       );

//   Widget _letter(String ch, double p) => Opacity(
//         opacity: p,
//         child: Transform.translate(
//           offset: Offset(0, 20 * (1 - p)),
//           child: Text(ch, style: syne(36, weight: FontWeight.w800)),
//         ),
//       );
// }



// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'home_screen.dart';
// import 'theme.dart';

// const creatorName = 'Faheem Fayaz';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   // How long the animation itself runs
//   late final AnimationController _c = AnimationController(
//     vsync: this,
//     duration: const Duration(milliseconds: 2800),
//   );

//   // How long the final scene stays on screen after the animation ends
//   static const _hold = Duration(milliseconds: 1500);

//   bool _left = false;

//   @override
//   void initState() {
//     super.initState();
//     _c
//         .forward()
//         .then((_) => Future.delayed(_hold))
//         .then((_) => _goHome());
//   }

//   void _goHome() {
//     if (_left || !mounted) return;
//     _left = true;
//     Navigator.of(context).pushReplacement(PageRouteBuilder(
//       transitionDuration: const Duration(milliseconds: 500),
//       pageBuilder: (_, __, ___) => const HomeScreen(),
//       transitionsBuilder: (_, anim, __, child) =>
//           FadeTransition(opacity: anim, child: child),
//     ));
//   }

//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: C.bg,
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: _goHome, // tap to skip
//         child: Center(
//           child: AnimatedBuilder(
//             animation: _c,
//             builder: (context, _) {
//               final t = _c.value;

//               double seg(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
//                   curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

//               final spread = seg(0.00, 0.40, Curves.elasticOut);
//               final fadeIn = seg(0.00, 0.10);
//               final title = seg(0.55, 0.85);
//               final by = seg(0.80, 1.00);

//               return Column(mainAxisSize: MainAxisSize.min, children: [
//                 // Blocks: burst out from center, then color wave
//                 Row(mainAxisSize: MainAxisSize.min, children: [
//                   for (var i = 0; i < 10; i++)
//                     _block(
//                       i: i,
//                       spread: spread,
//                       fade: fadeIn,
//                       wave: seg(0.35 + i * 0.03, 0.35 + i * 0.03 + 0.14,
//                           Curves.linear),
//                     ),
//                 ]),
//                 const SizedBox(height: 28),

//                 // Title: fades in while letter spacing tightens
//                 Opacity(
//                   opacity: title,
//                   child: Text(
//                     'StudyBlock',
//                     style: syne(36, weight: FontWeight.w800)
//                         .copyWith(letterSpacing: 14 * (1 - title)),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 Opacity(
//                   opacity: by,
//                   child: Text('by $creatorName',
//                       style: mono(13, color: C.muted)
//                           .copyWith(letterSpacing: 2)),
//                 ),
//               ]);
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _block({
//     required int i,
//     required double spread,
//     required double fade,
//     required double wave,
//   }) {
//     const slot = 22.0; // block width 16 + margins 3 + 3
//     final fromCenter = (4.5 - i) * slot; // distance to the middle of the row
//     final pulse = math.sin(math.pi * wave); // 0 -> 1 -> 0 as the wave passes
//     final settled = wave >= 1.0 ? 1.0 : wave; // stays green after wave passes

//     return Opacity(
//       opacity: fade,
//       child: Transform.translate(
//         offset: Offset(fromCenter * (1 - spread), 0),
//         child: Transform.rotate(
//           angle: math.pi * 1.5 * (1 - spread.clamp(0.0, 1.0)),
//           child: Transform.scale(
//             scale: 1 + 0.6 * pulse,
//             child: Container(
//               width: 16,
//               height: 16,
//               margin: const EdgeInsets.symmetric(horizontal: 3),
//               decoration: BoxDecoration(
//                 color: Color.lerp(
//                   C.blue,
//                   i < 5 ? C.blue : C.green,
//                   settled,
//                 ),
//                 borderRadius: BorderRadius.zero,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'theme.dart';

const creatorName = 'Faheem Fayaz';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Intro animation
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  // Exit animation (splash content slides up and fades)
  late final AnimationController _out = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  // How long the final scene stays on screen
  static const _hold = Duration(milliseconds: 1500);

  bool _left = false;

  @override
  void initState() {
    super.initState();
    _c
        .forward()
        .then((_) => Future.delayed(_hold))
        .then((_) => _goHome());
  }

  void _goHome() {
    if (_left || !mounted) return;
    _left = true;

    // Splash content slides up + fades
    _out.forward();

    // Home screen rises in underneath at the same time
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) => const HomeScreen(),
      transitionsBuilder: (_, anim, __, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ));
  }

  @override
  void dispose() {
    _c.dispose();
    _out.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goHome, // tap to skip
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_c, _out]),
            builder: (context, _) {
              final t = _c.value;

              double seg(double a, double b,
                      [Curve curve = Curves.easeOutCubic]) =>
                  curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

              final glow = seg(0.45, 0.90, Curves.easeInOut);
              final title = seg(0.60, 0.85);
              final by = seg(0.80, 1.00);

              final e = Curves.easeInCubic.transform(_out.value);

              return Opacity(
                opacity: 1 - e,
                child: Transform.translate(
                  offset: Offset(0, -80 * e),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // Glow + flipping blocks
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        _glow(glow),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          for (var i = 0; i < 10; i++)
                            _block(
                              i: i,
                              // first ripple: blocks flip into view
                              enter: seg(i * 0.03, i * 0.03 + 0.18),
                              // second ripple: blocks flip to their other side
                              flip: seg(0.35 + i * 0.035,
                                  0.35 + i * 0.035 + 0.20, Curves.easeInOut),
                            ),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Opacity(
                      opacity: title,
                      child: Transform.translate(
                        offset: Offset(0, 18 * (1 - title)),
                        child: Text('StudyBlock',
                            style: syne(36, weight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Opacity(
                      opacity: by,
                      child: Text('by $creatorName',
                          style: mono(13, color: C.muted)
                              .copyWith(letterSpacing: 2)),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Soft blue (left) to green (right) glow behind the row
  Widget _glow(double g) {
    Color a(Color c, double o) => c.withAlpha((255 * o * g).round());
    return Container(
      width: 200,
      height: 16,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: a(C.blue, 0.45),
            blurRadius: 70,
            spreadRadius: 12,
            offset: const Offset(-55, 0),
          ),
          BoxShadow(
            color: a(C.green, 0.45),
            blurRadius: 70,
            spreadRadius: 12,
            offset: const Offset(55, 0),
          ),
        ],
      ),
    );
  }

  // One 3D flipping block
  Widget _block({
    required int i,
    required double enter,
    required double flip,
  }) {
    const halfPi = 1.5707963267948966;
    const pi = 3.141592653589793;

    // -90deg (edge-on, invisible) -> 0deg (front) -> 180deg (back)
    final angle = -halfPi * (1 - enter) + pi * flip;
    final isBack = angle > halfPi;

    final frontColor = C.blue;
    final backColor = i < 5 ? C.blue : C.green;

    return Opacity(
      opacity: (enter * 3).clamp(0.0, 1.0),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.004) // perspective
          ..rotateY(angle),
        child: Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isBack ? backColor : frontColor,
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
    );
  }
}