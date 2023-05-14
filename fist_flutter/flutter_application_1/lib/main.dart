import 'package:english_words/english_words.dart';
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
        title: "My App",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange)
        ),
        home: MyHomePage()
        ),
      );
  }}


class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var histories = <WordPair>[];

  GlobalKey? historyListKey;

  void getNext() {
    histories.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }


  var favorites = <WordPair>[];

  void toggleFavorite() {
    if(favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
  
  
  void toggleHistories() {
    histories.add(current);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    Widget page;
    switch (selectedIndex) {
      case 0: 
        page = GeneratorPage();
        break;
      case 1:
        page = MyFavorite();
        break;
      default: 
        throw UnimplementedError(' no widget for $selectedIndex');
    }
    
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),      
    );
    return LayoutBuilder(
      builder: (context, constrains) {
        if(constrains.maxWidth < 450) {
          return Column(
            children: [
              Expanded(child: mainArea),
              SafeArea(child: 
                BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: 'Like',
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (value) => {
                    setState(() {
                      selectedIndex = value;
                    }),
                  },
                ) 
              ),
            ],
          );
        } else {
          return Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constrains.maxWidth > 600, 
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text("Home"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text("Like"),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: mainArea,
              ),
            ],
          );
        }
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    // var theme = Theme.of(context);
    IconData icon;
    if(appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // show histories
            Expanded(
              flex: 3,
              child: HistoryListView(),
            ),
            BigCard(pair: pair),
            SizedBox(height: 10,),
            
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () => {
                  appState.toggleFavorite(),                
                },
                label: Text("Like"),
                icon: Icon(icon)
                ),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: () {
                    print("button pressed");
                    appState.getNext();
                  }, 
                  child: Text('next')
                ),
              ],
            ),
          ],
        ),
      );
  }
}


class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}): super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  @override
  Widget build(BuildContext context) {
    return Column();
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
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary
    );
    return Card(
      color: theme.colorScheme.primary,
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase, 
          style: style, 
          semanticsLabel: "${pair.first} ${pair.second}",),
      ),
    );
  }
}

class MyFavorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var myState = context.watch<MyAppState>();
    var favorites = myState.favorites;
    
    if(favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }

    return Center(
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text('You have ${favorites.length} favorites:'),
          ),
          for(var i in favorites)
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text(i.asLowerCase),
            )
        ],
      ),
    );
  }

}