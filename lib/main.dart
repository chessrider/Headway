import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:headway/chat.dart';

import 'Experts.dart';
import 'books.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyappState createState() => _MyappState();
}

class _MyappState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(
              selected: 0,
            ),
        '/chat': (context) => const Chat(),
      },
    );
  }
}

class Home extends StatefulWidget {
  late int selected;

  Home({Key? key, required this.selected}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int selected;
  late PageController? controller;

  @override
  void initState() {
    super.initState();
    selected = widget.selected;
    controller = PageController(initialPage: selected);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        child: CustomPaint(
          painter: PaintAppBar(),
          child: ClipPath(
            clipper: ClipAppBar(), //my CustomClipper
            child: Container(
              height: 200,
              decoration: const BoxDecoration(color: Color.fromRGBO(241, 245, 249, 1)),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(left: 30),
                      height: 50,
                      width: 50,
                      child: Image.asset("assets/images/Expertavatar.png"),
                    ),
                  ),
                  Center(child: Text(selected == 0 ? "Experts" : "Books", style: GoogleFonts.dongle(fontSize: 40, fontWeight: FontWeight.w700))),
                ],
              ),
            ),
          ),
        ),
        preferredSize: const Size.fromHeight(120),
      ),
      resizeToAvoidBottomInset: true,
      body: Material(
        child: Stack(
          children: [
            PageView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              onPageChanged: (page) => setState(() => selected = page),
              children: [
                Experts(
                  experts: [
                    Expert("Name", "Психолог", "assets/images/avatars/ava1.png"),
                    Expert("Name", "Психолог", "assets/images/avatars/ava1.png"),
                    Expert("Name", "Психолог", "assets/images/avatars/ava1.png"),
                  ],
                  controller: controller!,
                ),
                const Books(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipShadowPath(
        shadow: const BoxShadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 4, spreadRadius: 4),
        clipper: ClipBody(),
        child: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.only(top: 10),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle, size: 30, color: selected == 0 ? const Color.fromRGBO(142, 189, 237, 1) : Colors.black),
                    const SizedBox(height: 5),
                    Text(
                      "Experts",
                      style: TextStyle(color: selected == 0 ? const Color.fromRGBO(137, 169, 227, 1) : Colors.black),
                    ),
                  ],
                ),
                onTap: () => setState(() {
                  selected = 0;
                  controller?.animateToPage(selected, duration: const Duration(milliseconds: 350), curve: Curves.linear);
                }),
              ),
              GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_outlined, size: 30, color: selected == 1 ? const Color.fromRGBO(255, 229, 92, 1) : Colors.black),
                    const SizedBox(height: 5),
                    Text("Books", style: TextStyle(color: selected == 1 ? const Color.fromRGBO(255, 194, 50, 1) : Colors.black)),
                  ],
                ),
                onTap: () {
                  setState(() => selected = 1);
                  controller?.animateToPage(selected, duration: const Duration(milliseconds: 350), curve: Curves.linear);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaintAppBar extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(0, size.height - 40, 40, size.height - 40);
    path.lineTo(size.width - 40, size.height - 40);
    path.quadraticBezierTo(size.width, size.height - 40, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawShadow(path, Colors.black45, 3.0, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ClipAppBar extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(0, size.height - 40, 40, size.height - 40);
    path.lineTo(size.width - 40, size.height - 40);
    path.quadraticBezierTo(size.width, size.height - 40, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class PaintBody extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 20);
    path.lineTo(20, 20);
    path.quadraticBezierTo(0, 20, 0, 0);
    path.close();
    canvas.drawPaint(const Shadow(color: Colors.black45, offset: Offset(0, 0), blurRadius: 0).toPaint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ClipBody extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 20);
    path.lineTo(20, 20);
    path.quadraticBezierTo(0, 20, 0, 0);
    path.shift(const Offset(0, 3));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ClipShadowPath extends StatelessWidget {
  final Shadow shadow;
  final CustomClipper<Path> clipper;
  final Widget child;

  const ClipShadowPath({
    Key? key,
    required this.shadow,
    required this.clipper,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: UniqueKey(),
      painter: _ClipShadowShadowPainter(clipper: clipper, shadow: shadow),
      child: ClipPath(child: child, clipper: clipper),
    );
  }
}

class _ClipShadowShadowPainter extends CustomPainter {
  final Shadow shadow;
  final CustomClipper<Path> clipper;

  _ClipShadowShadowPainter({required this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = shadow.toPaint();
    var clipPath = clipper.getClip(size).shift(shadow.offset);
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
