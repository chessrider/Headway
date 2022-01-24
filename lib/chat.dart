import 'dart:async';
import 'dart:io';

import 'dart:developer' as dev;

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:headway/Experts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:dialogflow_grpc/dialogflow_grpc.dart';
import 'package:dialogflow_grpc/generated/google/cloud/dialogflow/v2beta1/session.pb.dart';
import 'package:path_provider/path_provider.dart';
import 'books.dart';
import 'main.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with SingleTickerProviderStateMixin {
  final List<Widget> _messages = [const SizedBox(height: 100)];
  final TextEditingController _textController = TextEditingController();
  late Expert expert;
  late double opacity;

  bool _isRecording = false;
  bool _isAnimation = false;

  final RecorderStream _recorder = RecorderStream();
  late StreamSubscription _recorderStatus;
  late StreamSubscription<List<int>> _audioStreamSubscription;
  late BehaviorSubject<List<int>> _audioStream;
  late DialogflowGrpcV2Beta1 dialogflow;
  late Timer timer;
  late double width;

  @override
  void initState() {
    super.initState();
    opacity = 0;
    initPlugin();
  }

  @override
  void dispose() {
    _recorderStatus.cancel();
    try {
      _audioStreamSubscription.cancel();
    } catch (e) {}
    super.dispose();
  }

  Future<void> initPlugin() async {
    _recorderStatus = _recorder.status.listen((status) {
      if (mounted) {
        setState(() => _isRecording = status == SoundStreamStatus.Playing);
      }
    });

    await Future.wait([_recorder.initialize()]);
    final serviceAccount = ServiceAccount.fromString((await rootBundle.loadString('assets/credentials.json')));
    dialogflow = DialogflowGrpcV2Beta1.viaServiceAccount(serviceAccount);
  }

  void stopStream() async {
    await _recorder.stop();
    try {
      await _audioStreamSubscription.cancel();
    } catch (e) {}
    try {
      await _audioStream.close();
    } catch (e) {}
  }

  void handleSubmitted(text) async {
    if (_textController.text.isNotEmpty) {
      setState(() => _isAnimation = true);
      timer = Timer.periodic(const Duration(milliseconds: 200), (timer) => setState(() => opacity += 0.2));
      stopStream();
      ChatMessage message = ChatMessage(text: text, name: "You", type: true, ava: false, image: Image.asset(""));
      setState(() => _messages.insert(0, message));
      _textController.clear();

      DetectIntentResponse data = await dialogflow.detectIntent(text, 'ru-RU');
      for (var element in data.queryResult.fulfillmentMessages) {
        String fulfillmentText = element.text.text[0];
        if (fulfillmentText.isNotEmpty) {
          Widget message;
          if (!fulfillmentText.startsWith("Книга")) {
            message = ChatMessage(
              text: fulfillmentText,
              name: expert.name,
              type: false,
              ava: data.queryResult.fulfillmentMessages.indexOf(element) == 0,
              image: Image.asset(expert.ava, fit: BoxFit.cover),
            );
          } else {
            List<String> list = fulfillmentText.split(":")[1].split(",");
            message = Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                children: [
                  Container(
                    clipBehavior: Clip.hardEdge,
                    height: 100,
                    alignment: Alignment.center,
                    constraints: BoxConstraints(maxWidth: width),
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(5)),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
                        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                        child: Image.asset(allBooks[int.parse(list[index])].Image),
                      ),
                      itemCount: list.length,
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5), bottom: Radius.circular(15)),
                      ),
                      width: width,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text("Посмотреть", style: GoogleFonts.dongle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                    onTap: () {
                      recommendedBook.clear();
                      list.forEach((element) => recommendedBook.add(allBooks[int.parse(element)]));
                      Navigator.pop(context);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(selected: 1)));
                    },
                  ),
                ],
              ),
            );
          }
          await Future.delayed(
            Duration(
              milliseconds: data.queryResult.fulfillmentMessages.indexOf(element) == 0 ? Random().nextInt(3000) + 2000 : Random().nextInt(1500) + 500,
            ),
            () => setState(() => _messages.insert(0, message)),
          );
          if (data.queryResult.fulfillmentMessages.indexOf(element) == 0) {
            setState(() => _isAnimation = false);
            timer.cancel();
            final file = File('${(await getTemporaryDirectory()).path}/sound1.mp3');
            await file.writeAsBytes((await rootBundle.load('assets/sounds/sound1.mp3')).buffer.asUint8List());
            await AudioPlayer().play(file.path, isLocal: true);
          }
        }
      }
    }
  }

  void handleStream() async {
    String words = "";

    _recorder.start();

    _audioStream = BehaviorSubject<List<int>>();
    _audioStreamSubscription = _recorder.audioStream.listen((data) => _audioStream.add(data));

    var config = InputConfigV2beta1(
      encoding: 'AUDIO_ENCODING_LINEAR_16',
      languageCode: 'ru-RU',
      sampleRateHertz: 16000,
      singleUtterance: false,
      speechContexts: [
        SpeechContextV2Beta1(phrases: ['Dialogflow CX', 'Dialogflow Essentials', 'Action Builder', 'HIPAA'], boost: 20.0)
      ],
    );
    final responseStream = dialogflow.streamingDetectIntent(config, _audioStream);
    responseStream.listen((data) {
      setState(() {
        String transcript = data.recognitionResult.transcript;
        if (transcript.isNotEmpty) {
          _textController.text = _textController.text.substring(0, _textController.text.length - words.length);
          _textController.text += _textController.text.isEmpty ? transcript : transcript.toLowerCase();
          words = data.recognitionResult.isFinal ? "" : transcript;
          _textController.selection = TextSelection(baseOffset: _textController.text.length, extentOffset: _textController.text.length);
        }
      });
    }, onError: (e) {}, onDone: () {});
  }

  @override
  Widget build(BuildContext context) {
    expert = ModalRoute.of(context)!.settings.arguments as Expert;
    width = MediaQuery.of(context).size.width * 0.6;
    return Material(
      child: Scaffold(
        appBar: PreferredSize(
          child: CustomPaint(
            painter: PaintAppBar(),
            child: ClipPath(
              clipper: ClipAppBar(), //my CustomClipper
              child: Container(
                decoration: const BoxDecoration(color: Color.fromRGBO(241, 245, 249, 1)),
                child: Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
                        margin: const EdgeInsets.only(left: 30),
                        height: 50,
                        width: 50,
                        child: Image.asset(expert.ava, fit: BoxFit.cover),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Text(expert.name, style: GoogleFonts.dongle(fontSize: 40, fontWeight: FontWeight.w700)),
                    ),
                    Row(
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isAnimation ? (opacity + 0.66) % 1 : 0,
                          child: Container(
                            margin: const EdgeInsets.only(left: 3, top: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isAnimation ? (opacity + 0.33) % 1 : 0,
                          child: Container(
                            margin: const EdgeInsets.only(left: 2, top: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isAnimation ? opacity % 1 : 0,
                          child: Container(
                            margin: const EdgeInsets.only(left: 2, top: 6),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          preferredSize: const Size.fromHeight(110),
        ),
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        body: Column(children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Icon(_isRecording ? Icons.mic_off : Icons.mic),
                    ),
                    onTap: _isRecording ? stopStream : handleStream,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(40)),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              onSubmitted: handleSubmitted,
                              decoration: const InputDecoration.collapsed(hintText: "Send a message"),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () => handleSubmitted(_textController.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final String name;
  final bool type;
  final bool ava;
  final Image image;

  const ChatMessage({Key? key, required this.text, required this.name, required this.type, required this.ava, required this.image}) : super(key: key);

  Widget otherMessage(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Visibility(
          visible: ava,
          child: Row(
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(right: 10),
                child: image,
              ),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor, borderRadius: BorderRadius.circular(15)),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget myMessage(context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      decoration: BoxDecoration(color: Theme.of(context).backgroundColor.withOpacity(0.7), borderRadius: BorderRadius.circular(15)),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: type ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6, minWidth: MediaQuery.of(context).size.width * 0.15),
        margin: const EdgeInsets.symmetric(vertical: 1.5),
        child: type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
