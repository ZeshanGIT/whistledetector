import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:after_layout/after_layout.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:gradual_stepper/gradual_stepper.dart';
import 'package:intent/intent.dart' as MyIntent;
import 'package:intent/action.dart' as MyAction;
import 'package:whistledetector/about.dart';

import 'circle_wave_progress.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

enum CALLBACK_ACTION {
  CALL_TO,
  RING_THIS,
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/about': (_) => About(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Whistle Counter',
      theme: ThemeData(primaryColor: Colors.white, fontFamily: 'JS'),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AfterLayoutMixin, SingleTickerProviderStateMixin {
  static const int THRESHOLD = 15000;

  bool temp;
  bool isHomePage = true;

  CALLBACK_ACTION callback = CALLBACK_ACTION.CALL_TO;

  int tempTimes;

  double tempProgress = 100;

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() {
      String text = textEditingController.text;
      if (text == '0') {
        textEditingController.clear();
      }
    });
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    animationController.addListener(() {
      if (animationController.isCompleted) {
        tempProgress = (times / tempTimes) * 100;
      }
    });
    animationController.reset();
    tween = Tween(begin: 0.0, end: 1.0).animate(animationController);
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    const platform = const MethodChannel('wd/aud');
    await platform.invokeMethod('perm');
    await platform.invokeMethod('stop');
    await platform.invokeMethod('start');
  }

  int times = 0;
  TextEditingController textEditingController = TextEditingController();
  @override
  dispose() async {
    const platform = const MethodChannel('wd/aud');
    await platform.invokeMethod('stop');
    super.dispose();
  }

  AnimationController animationController;
  Animation tween;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.pink,
        body: isHomePage
            ? AnimatedOpacity(
                opacity: isHomePage ? 1 : 0,
                duration: Duration(milliseconds: 300),
                child: buildHomePage(context),
              )
            : AnimatedOpacity(
                opacity: isHomePage ? 0 : 1,
                duration: Duration(
                  milliseconds: 300,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: tween,
                        builder: (_, child) {
                          return CircleWaveProgress(
                            childText: Text(
                              '$times Whistles\nLeft',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.pink,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            progress: lerpDouble(
                              tempProgress,
                              (times / tempTimes) * 100.0,
                              tween.value,
                            ),
                            waveColor: Colors.white,
                            backgroundColor: Colors.pink,
                          );
                        },
                        child: CircleWaveProgress(
                          childText: Text(
                            '$times Whistles\nLeft',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.pink,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          progress: (times / tempTimes) * 100.0,
                          waveColor: Colors.white,
                          backgroundColor: Colors.pink,
                        ),
                      ),
                      SizedBox(height: 64),
                      RaisedButton(
                        color: Colors.white,
                        shape: StadiumBorder(),
                        onPressed: () {
                          setState(() {
                            isHomePage = true;
                            tempTimes = 0;
                            times = 0;
                          });
                          FlutterRingtonePlayer.stop();
                        },
                        padding: EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget buildHomePage(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Whistle Counter',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: GradualStepper(
                    initialValue: 0,
                    minimumValue: 0,
                    maximumValue: 10,
                    stepValue: 1,
                    backgroundColor: Colors.white24,
                    counterTextStyle: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    onChanged: (int value) {
                      setState(() {
                        times = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  'When done,',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: DropdownButton<CALLBACK_ACTION>(
                    iconEnabledColor: Colors.pink,
                    value: callback,
                    style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'JS'),
                    items: [
                      DropdownMenuItem(
                        value: CALLBACK_ACTION.CALL_TO,
                        child: Text(
                          'Call to',
                        ),
                      ),
                      DropdownMenuItem(
                        value: CALLBACK_ACTION.RING_THIS,
                        child: Text(
                          'Ring this phone',
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        callback = val;
                      });
                    },
                  ),
                ),
                SizedBox(height: 16),
                callback == CALLBACK_ACTION.CALL_TO
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: TextField(
                          controller: textEditingController,
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 10,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                          onChanged: (txt) {},
                        ),
                      )
                    : Container(),
                SizedBox(height: 8),
                Text(
                  'Ignore zeros at the beginning',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 32),
                RaisedButton(
                  onPressed: () {
                    if (times == 0) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(
                            'Count cannot be zero !',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            "You're gonna eat it raw ?\n\nReally ? 🤨",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          actions: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(
                                      "Dayum Mann !",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      "If you've been doing this often, you're messed for real.\nPlease cosult a doctor real quick.",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    actions: <Widget>[
                                      RaisedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("STFU"),
                                        color: Colors.white,
                                      ),
                                      RaisedButton(
                                        color: Colors.pink,
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("TYSM"),
                                      )
                                    ],
                                  ),
                                );
                              },
                              color: Colors.white,
                              child: Text("Yes, I'm a PIGEON"),
                            ),
                            RaisedButton(
                              color: Colors.pink,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('No'),
                            )
                          ],
                        ),
                      );
                    } else if (callback == CALLBACK_ACTION.CALL_TO &&
                        textEditingController.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: Text('Phone Number cannot be empty'),
                            content: Text(
                              "It's good that you're trying to call Shiva, but you cannot technically call him on the phone",
                            ),
                            actions: <Widget>[
                              RaisedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: Text('Thought so'),
                                        content: Text(
                                          'So, Shiva = Shi + Va,\nmeaning "That which is not". So, he is basically nothingness.',
                                        ),
                                        actions: <Widget>[
                                          RaisedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            color: Colors.white,
                                            child: Text('Whatever'),
                                          ),
                                          RaisedButton(
                                            color: Colors.pink,
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Get it'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                color: Colors.white,
                                child: Text("Didn't get it"),
                              ),
                              RaisedButton(
                                color: Colors.pink,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Got it'),
                              )
                            ],
                          );
                        },
                      );
                    } else if (callback == CALLBACK_ACTION.CALL_TO &&
                        textEditingController.text.length < 10) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Phone Number should be 10 digits long'),
                          content: Text(
                              'The last time I checked, you were aged enough to know that an Indian Phone Number is 10 digits long'),
                          actions: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('So Sorry'),
                              color: Colors.white,
                            ),
                            RaisedButton(
                              color: Colors.pink,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Sorry'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      setState(() {
                        tempTimes = times;
                        isHomePage = false;
                      });
                      buildFuture();
                    }
                  },
                  shape: StadiumBorder(),
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Text(
                    "Start Cookin'",
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              padding: EdgeInsets.all(8.0),
              color: Colors.white,
              icon: Image.asset('assets/about.png'),
              iconSize: 64,
              onPressed: () {
                Navigator.of(context).pushNamed('/about');
              },
            ),
          ),
        ],
      ),
    );
  }

  bool tempMinusOne = false;

  Future<dynamic> buildFuture() {
    return Future.delayed(
      Duration(milliseconds: 200),
      () async {
        const platform = const MethodChannel('wd/aud');
        int k = await platform.invokeMethod('maxAmp');
        if (k < THRESHOLD) {
          if (tempMinusOne && times != 0) {
            setState(() {
              --times;
            });
            animationController.reset();
            animationController.forward();
            tempMinusOne = false;
          }
        } else
          tempMinusOne = true;
        print('^^^^^^^^^^^^^^^^^$times');
        if (times > 0)
          buildFuture();
        else {
          if (callback == CALLBACK_ACTION.CALL_TO) {
            MyIntent.Intent()
              ..setAction(MyAction.Action.ACTION_CALL)
              ..setData(Uri(scheme: 'tel', path: textEditingController.text))
              ..startActivity().catchError((e) => print(e));
          } else {
            FlutterRingtonePlayer.play(
              android: AndroidSounds.ringtone,
              ios: IosSounds.glass,
              looping: true,
              volume: 0.1,
              asAlarm: true,
            );
          }
        }
      },
    );
  }
}
