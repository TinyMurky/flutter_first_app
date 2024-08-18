import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

// App 本身也是widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  // it create the app-wide state, named app, define visual theme
  // and set "home" widget, the starting point of app
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Namer App',
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue)),
          home: MyHomePage(),
        ));
  }
}

// 以上的部份分拆成下面兩個部份

// THis defined state, 有很多方法可以改state
// changeNotifier是其中一種，他會通知所有watch他的widget，他的狀態改變了
// MyAppState被Created and provided to whole app using "ChangeNotifierProvider" in "MyApp"
// 因此所有在app 裡的widget都可以使用這個state
class MyAppState extends ChangeNotifier {
  // 可以直接watch 後 從state.current拿出這個值
  var current = WordPair.random();

  // 這個function也可以直接state.getNext() 拿出來
  void getNext() {
    current = WordPair.random(); // current 換一個新的值
    notifyListeners(); // 屬於ChangeNotifier的特殊function, 可以通知所有"watch"這個state的widget
  }

  // like Function放這邊
  var favorites = <WordPair>[];

  WordPair toggleFavorite(WordPair wordPair) {
    final isInFavorites = favorites.contains(wordPair);

    if (isInFavorites) {
      favorites.remove(wordPair);
    } else {
      favorites.add(wordPair);
    }

    notifyListeners(); // 要通知所有watch的人
    return wordPair;
  }
}

// class MyHomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // "build" 會在widget circumstances change 的時候都自動呼叫
//     var appState = context.watch<MyAppState>(); // MyHomePage 用 watch來監控state

//     // 把Text(appState.current.asLowerCase) 的錢兩部份拉出成一個新的 widget
//     var pair = appState.current;

//     // heart Icon for favorite button
//     IconData heartIcon;
//     if (appState.favorites.contains(pair)) {
//       heartIcon = Icons.favorite;
//     } else {
//       heartIcon = Icons.favorite_border;
//     }

//     return Scaffold(
//         // "build" 一定要回傳一個或nested tree widget, Scaffold是一種widget
//         body: Center(
//       child: Column(
//         // 8. "Column" 是一種 "layout", column 會把最上層的child放在最上層
//         // 8. 用mainAxisAlignment來把Column裡面的child放在y軸的中間
//         // 8. 用widget模式查看(debug的時候最上面紅色方形的右邊可以看到放大鏡，按下查看)
//         // 8. 發現column的寬旗使和內容物一樣寬，代表x軸置中需要再上一層，
//         // 8. column 上 右鍵 refactor => wrap with center
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Text('A random AWESOME idea:'), // 連Text都是widget
//           // Text(appState.current
//           // .asLowerCase), // 這邊從appState取值, 拿出該class下面的member "current" 也就是 "WordPair" (class 裡的值可以直接拿出來) wordPair 下面也有asPascalCase asSnakeCase
//           BigCard(
//               pair:
//                   pair), // 把原本的Text(pair:.asLowerCase) 右鍵 => refactor... => extract widget
//           SizedBox(
//             height: 15.0, // sized box的功能單純是佔據一個空間
//           ),
//           // Next button, 10: 當我們需要橫向的時候，就 右鍵 refactor wrap with row
//           Row(
//             // 11. 加上row之後 五絣會跑到該row的最左邊，一樣要用下面這行置中
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton.icon(
//                   // ElevatedButton.icon() 是帶有 icon的button
//                   onPressed: () {
//                     appState.toggleFavorite(pair);
//                   },
//                   icon: Icon(heartIcon),
//                   label: Text("Favorite")),
//               SizedBox(width: 10),
//               ElevatedButton(
//                 onPressed: () {
//                   print('button pressed!');
//                   appState.getNext(); // 呼叫
//                 },
//                 child: Text('Next'),
//               ),
//             ],
//           )
//         ], // Flutter喜歡最後多加一個逗號
//       ),
//     ));
//   }
// }
// 以上的部份分拆成下面兩個部份

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var currentSelectedPage = 0;

  @override
  Widget build(BuildContext context) {
    Widget page; // 一定要再被使用前先把值田進去
    switch (currentSelectedPage) {
      case 0:
        page = GeneratorPage();
      // break; // dart 不需要特別加break
      case 1:
        page = Placeholder();
      // break;
      default:
        throw UnimplementedError('no widget for $currentSelectedPage');
    }

    return Scaffold(
        body: Row(
      children: [
        SafeArea(
            child: NavigationRail(
          extended: true,
          destinations: [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.favorite),
              label: Text('Favorite'),
            ),
          ],
          selectedIndex: currentSelectedPage,
          onDestinationSelected: (value) {
            print('selected $value');
            // 下面這樣寫不對，要放在 "setState"<
            // setState 和notifyListeners類似，保證畫面更新
            // currentSelectedPage = value;
            setState(() {
              currentSelectedPage = value;
            });
          },
        )),
        Expanded(
            // expand 會greedy 佔據畫面
            child: Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: page,
        ))
      ],
    ));
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // "build" 會在widget circumstances change 的時候都自動呼叫
    var appState = context.watch<MyAppState>(); // MyHomePage 用 watch來監控state

    // 把Text(appState.current.asLowerCase) 的錢兩部份拉出成一個新的 widget
    var pair = appState.current;

    // heart Icon for favorite button
    IconData heartIcon;
    if (appState.favorites.contains(pair)) {
      heartIcon = Icons.favorite;
    } else {
      heartIcon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        // 8. "Column" 是一種 "layout", column 會把最上層的child放在最上層
        // 8. 用mainAxisAlignment來把Column裡面的child放在y軸的中間
        // 8. 用widget模式查看(debug的時候最上面紅色方形的右邊可以看到放大鏡，按下查看)
        // 8. 發現column的寬旗使和內容物一樣寬，代表x軸置中需要再上一層，
        // 8. column 上 右鍵 refactor => wrap with center
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text('A random AWESOME idea:'), // 連Text都是widget
          // Text(appState.current
          // .asLowerCase), // 這邊從appState取值, 拿出該class下面的member "current" 也就是 "WordPair" (class 裡的值可以直接拿出來) wordPair 下面也有asPascalCase asSnakeCase
          BigCard(
              pair:
                  pair), // 把原本的Text(pair:.asLowerCase) 右鍵 => refactor... => extract widget
          SizedBox(
            height: 15.0, // sized box的功能單純是佔據一個空間
          ),
          // Next button, 10: 當我們需要橫向的時候，就 右鍵 refactor wrap with row
          Row(
            // 11. 加上row之後 五絣會跑到該row的最左邊，一樣要用下面這行置中
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  // ElevatedButton.icon() 是帶有 icon的button
                  onPressed: () {
                    appState.toggleFavorite(pair);
                  },
                  icon: Icon(heartIcon),
                  label: Text("Favorite")),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  print('button pressed!');
                  appState.getNext(); // 呼叫
                },
                child: Text('Next'),
              ),
            ],
          )
        ], // Flutter喜歡最後多加一個逗號
      ),
    );
  }
}

// 把原本的Text(pair:.asLowerCase) 右鍵 => refactor... => extract widget
// 生出來的新的widget
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    // 4. 加上顏色，用app的顏色
    final theme = Theme.of(context);

    // 5. 幫Text加上 "style"
    // a. theme.textTheme 可以取得app(從context)的 font theme 像是bodyMedium (for standard text of medium size), caption (for captions of images), or headlineLarge (for large headlines)
    // b. "display***"  代表文字表現(display typeface) displayMedium 代表 "display styles are reserved for short, important text"
    // c. displayMedium 有可能是 "null", 但由於是codelab我很確定不是null，所以用後面的!表示不是null
    // d. "copyWith" 從 displayMedium把text style with the changes you define()複製
    final style = theme.textTheme.displayMedium!.copyWith(
        // ctrl + shift + space 可以看到裡面有什麼可以用
        color: theme
            .colorScheme.onPrimary, // 和card 對應，有 .onPrimary, .onSecondary, ...
        fontWeight: FontWeight.bold);

    // 1. return Text(pair.asLowerCase); // 一開始extract widget的時候會出現這一行，右鍵 => refactor => wrap with paddle
    // 3. 有的Paddle之後再一次 "Wrap with widget" 然後用Card
    return Card(
      // clipBehavior: Clip.hardEdge, // clip是裁剪超出去的時候用的
      elevation: 5.0, // shadow的範圍(控制這個卡的z軸)
      color: theme.colorScheme
          .primary, // 4. 幫card加上顏色, 還有.primary .secondary, .surface...
      // 也可以向下面這兩種這樣直接設定顏色
      // color: Colors.green,
      // color: Color.fromRGBO(0, 255, 0, 1.0),
      child: Padding(
        // 2. 下方padding時一個widget, 和css不同，padding不會是屬性
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: // 更多的Accessbility 請參考：https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibilityAccessibility
              "${pair.first} ${pair.second}", // 這個給殘障輔助用的, 把像是busmom拆成兩個字, bus mom好讀出來
        ),
      ),
    );
  }
}
