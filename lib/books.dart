import 'dart:math';

import 'package:flutter/material.dart';

class Books extends StatefulWidget {
  const Books({Key? key}) : super(key: key);

  @override
  _BooksState createState() => _BooksState();
}

class _BooksState extends State<Books> {
  @override
  Widget build(BuildContext context) {
    List<Widget> childrens = [];
    if (recommendedBook.isNotEmpty) childrens.add(const BookSection(heading: "Recommended"));
    childrens.add(const BookSection(heading: "Top"));
    childrens.add(const BookSection(heading: "All"));
    return ScrollConfiguration(behavior: MyBehavior(), child: ListView(children: childrens));
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class Book {
  final int id;
  final String name;
  final String author;
  final String Image;

  Book(this.id, {required this.author, required this.Image, required this.name});
}

class BookSection extends StatelessWidget {
  final String heading;

  const BookSection({Key? key, required this.heading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Book> bookList = [];
    if (heading == "Top") {
      for (int i = 0; i < 5; i++) {
        bookList.add(allBooks[Random().nextInt(allBooks.length)]);
      }
    } else if (heading == "Recommended") {
      bookList = recommendedBook;
    } else if (heading == "All") {
      bookList = allBooks;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: const EdgeInsets.only(left: 30), child: Text(heading, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700))),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.builder(
            itemBuilder: (ctx, i) => Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 15, right: 20),
                  constraints: const BoxConstraints(maxWidth: 170),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.27,
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Stack(
                          children: [
                            Container(
                              clipBehavior: Clip.hardEdge,
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 5,
                                    offset: const Offset(8, 8),
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                              child: Image.asset(
                                bookList[i].Image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.27,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Text(bookList[i].name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 2),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Text(bookList[i].author, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      )
                    ],
                  ),
                ),
              ],
            ),
            itemCount: bookList.length,
            scrollDirection: Axis.horizontal,
          ),
        )
      ],
    );
  }
}

List<Book> _allBooks = [
  Book(1, name: "Победи прокрас...", author: "Петр Людвиг", Image: "assets/images/book1.png"),
  Book(2, name: "Прокрастинация...", author: "Эйлин Леви", Image: "assets/images/book2.png"),
  Book(3, name: "Прокрастинация ", author: "Хенри Шувенбург", Image: "assets/images/book3.png"),
  Book(4, name: "Коммуникация...", author: "Викулова Лидия", Image: "assets/images/book4.png"),
  Book(5, name: "Психология ком...", author: "Болотова Алла", Image: "assets/images/book5.png"),
  Book(6, name: "Эффективные ко...", author: "Альпина Паблишер", Image: "assets/images/book6.png"),
  Book(7, name: "Тревожность. 1...", author: "Лорна Гарано", Image: "assets/images/book7.png"),
  Book(8, name: "Лорна Гарано, ...", author: "Аннибали Дж", Image: "assets/images/book8.png"),
  Book(9, name: "Тревога и бесп...", author: "Девид Кларк", Image: "assets/images/book9.png"),
  Book(10, name: "Исцели свои т...", author: "Беверли Энгл", Image: "assets/images/book10.png"),
  Book(11, name: "Год заботы о ...", author: "Дженніфер Ештон", Image: "assets/images/book11.png"),
  Book(12, name: "Как работать ...", author: "Тимоти Феррис", Image: "assets/images/book12.png"),
  Book(13, name: "Жизнь на полн...", author: "Джим Лоэр", Image: "assets/images/book13.png"),
  Book(14, name: "Жить на полну...", author: "Майкл Хайятт", Image: "assets/images/book14.png"),
];

List<Book> get allBooks {
  return [..._allBooks];
}

List<Book> recommendedBook = [];
