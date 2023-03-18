import 'package:russian_words/russian_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'RandomWords App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  //Получаем новое значение
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Случайный набор слов:'),
            //Text(appState.current.asLowerCase),
            SizedBox(height: 20),
            BigCard(pair: pair),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                appState.getNext();
              },
              child: Text('Следующий'),
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styleth = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CardText(theme: theme, paireText: pair.first, styleth: styleth),
        _CardText(theme: theme, paireText: pair.second, styleth: styleth),
      ],
    );
  }
}

class _CardText extends StatelessWidget {
  const _CardText({
    required this.theme,
    required this.paireText,
    required this.styleth,
  });

  final ThemeData theme;
  final String paireText;
  final TextStyle styleth;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(paireText, style: styleth),
      ),
    );
  }
}
