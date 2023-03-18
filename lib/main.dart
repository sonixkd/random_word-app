import 'package:russian_words/russian_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Функция делает первую букву в тексте заглавной (прописной)
String upperfirst(String name) =>
    '${name[0].toUpperCase()}${name.substring(1)}';

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
  var history = <WordPair>[];
  GlobalKey? historyListKey;

  //Получаем новое значение
  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  void deleteAllFavorite() {
    favorites.clear();
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

//Страничка избранного
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('Избранного пока нет'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'У вас есть '
            '${appState.favorites.length} избранных:',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (var pair in appState.favorites)
          ListTile(
            //Icon(Icons.favorite),
            leading: IconButton(
              icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
              color: theme.colorScheme.primary,
              onPressed: () {
                appState.removeFavorite(pair);
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(upperfirst(pair.first)),
                SizedBox(width: 15),
                Text(upperfirst(pair.second)),
              ],
            ),
          ),
        ElevatedButton.icon(
          onPressed: () {
            appState.deleteAllFavorite();
          },
          icon: Icon(Icons.delete),
          label: Text('Удалить все'),
        ),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 1; //Выбранный элемент меню | Изначальный экран
  var selectIndexLast = 1; //Запоминаем последний выбранный элемент
  var selectedMenuState = false; //Состояние меню открыто полностью или закрыто
  Widget? lastPage; //Запоминаем предыдущий действующий виджет перед рендерингом
  var variablePress = 0; //элемент меню | false - не нажат | true был нажат

  @override
  Widget build(BuildContext context) {
    Widget? page;

    switch (selectedIndex) {
      case 0:
        selectedMenuState = (selectedMenuState == true)
            ? selectedMenuState = false
            : selectedMenuState = true;
        page = lastPage;
        selectedIndex = selectIndexLast;
        if (variablePress == 2) variablePress = 1;
        break;
      case 1:
        if (variablePress == 2) variablePress = 1;
        page = GeneratorPage();
        break;
      case 2:
        if (variablePress == 2) variablePress = 1;
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('Нет виджета для $selectedIndex');
    }

    final mediaQuery = MediaQuery.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      if (mediaQuery.size.width >= 300) {
        if (variablePress != 1) {
          selectedMenuState = constraints.maxWidth >= 600;
        } else {
          variablePress = 0;
        }
      }

      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: selectedMenuState, //constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.menu),
                    label: Text(''),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Главная'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Избранное'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectIndexLast = selectedIndex;
                    lastPage = page;
                    selectedIndex = value;
                    variablePress = 2;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Color.fromARGB(255, 253, 232, 236),
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    //Иконка
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          //Text('Случайный набор слов:'),
          SizedBox(height: 20),
          BigCard(pair: pair),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Нравится'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Следующий'),
              ),
            ],
          ),
          Spacer(flex: 1),
        ],
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
        child: Text(upperfirst(paireText), style: styleth),
      ),
    );
  }
}

//Лента истории
class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey();
  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(upperfirst(pair.first)),
                    Text(upperfirst(pair.second)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
