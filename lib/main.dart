import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ColorEvent { to_amber, to_lightBlue }

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<ColorBloc>(
      create: (context) => ColorBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _model = Provider.of<ColorBloc>(context, listen: false);
    return StreamBuilder(
      stream: _model._colorStateStream,
      initialData: Colors.amber,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Test"),
          ),
          body: Center(
            child: AnimatedContainer(
              color: snapshot.data,
              duration: Duration(milliseconds: 500),
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 2,
            ),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                child: Text("AMBER"),
                backgroundColor: Colors.amber,
                onPressed: () {
                  _model.eventSink.add(ColorEvent.to_amber);
                },
              ),
              SizedBox(
                width: 10,
              ),
              FloatingActionButton(
                child: Text("BLUE"),
                backgroundColor: Colors.lightBlue,
                onPressed: () {
                  _model.eventSink.add(ColorEvent.to_lightBlue);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ColorBloc {
  Color _color = Colors.amber;

  //* контроллер для событий изменения цвета
  StreamController<ColorEvent> _eventController =
      StreamController<ColorEvent>();
  //* синк для внесения в стрим данных о событии изменения цвета
  StreamSink<ColorEvent> get eventSink => _eventController.sink;

  //* контроллер для изменения цвета
  StreamController<Color> _colorStateController = StreamController<Color>();
  //* стрим с данными о цвете
  Stream<Color> get _colorStateStream => _colorStateController.stream;
  //* синк для внесения в стрим цвета
  StreamSink<Color> get _colorSink => _colorStateController.sink;

  //* ф-ия для изменения цвета. В зависимости от события в стрим цвета вносится цвет через синк цвета
  void _mapEventToColor(ColorEvent colorEvent) {
    if (colorEvent == ColorEvent.to_amber) {
      _color = Colors.amber;
    } else {
      _color = Colors.lightBlue;
    }

    _colorSink.add(_color);
  }

  ColorBloc() {
    //* конструктор блока. устанавливаем слушатель. Если получаем данные, включается выполнение ф-ии _mapEventToColor
    _eventController.stream.listen(_mapEventToColor);
  }

  dispose() {
    _eventController.close();
    _colorStateController.close();
  }
}
