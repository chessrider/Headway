import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Experts extends StatefulWidget {
  final List<Expert> experts;
  final PageController controller;

  const Experts({Key? key, required this.experts, required this.controller}) : super(key: key);

  @override
  _ExpertsState createState() => _ExpertsState();
}

class _ExpertsState extends State<Experts> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.elliptical(12, 17)),
          boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: -10, offset: Offset(0, 8))],
        ),
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.all(15),
              width: 50,
              height: 50,
              child: Image.asset(widget.experts[index].ava, fit: BoxFit.cover),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.experts[index].name,
                    style: GoogleFonts.robotoSlab(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.experts[index].description,
                    style: GoogleFonts.luxuriousScript(fontSize: 14, color: Colors.black45),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
            GestureDetector(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: const Icon(Icons.chat),
              ),
              onTap: () async {
                final result = await Navigator.pushNamed(context, "/chat", arguments: widget.experts[index]);
                print(result);
                if (result != null) {
                  setState(() => widget.controller.jumpToPage(1));
                }
              },
            ),
            const SizedBox(width: 10)
          ],
        ),
      ),
      itemCount: widget.experts.length,
    );
  }
}

class Expert {
  late String name;
  late String description;
  late String ava;

  Expert(this.name, this.description, this.ava);
}
