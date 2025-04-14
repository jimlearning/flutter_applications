import 'package:english_words/english_words.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/playground.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

// import 'package:riverpod_annotation/riverpod_annotation.dart' as riverpod_annotation;
import 'floating_control_toolbar.dart';

// void main() {
//   runApp(ProviderScope(child: MyApp()));
// }

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(home: DemoToolbarPage()),
    ),
  );
}

// class CounterNotifier extends StateNotifier<int> {
//   CounterNotifier() : super(0);
//   void increment() => state++;
// }

// final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
//   return CounterNotifier();
// });

// final counterProvider2 = StateProvider<int>((ref) {
//   return 0;
// });
// // Provider是Riverpod中最基础的只读提供者，这里需要明确指定是riverpod.Provider来避免与provider包的Provider产生歧义
// final counterProvider3 = riverpod_annotation.Provider<int>((ref) {
//   return 0;
// });

// ref.watch(counterProvider);
// ref.read(CounterNotifier.notifier).increment();

// // 需要先导入 riverpod_annotation 包中的 FutureProvider
// final userProvider = riverpod_annotation.FutureProvider<User>((ref) async {
//   return fetchUser();
// });

// final countProvider = riverpod_annotation.StreamProvider((ref) {
//   return Stream.periodic(Duration(seconds: 1), (i) => i);
// });

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => MyAppState(),
//       child: MaterialApp(
//         home: defaultTargetPlatform == TargetPlatform.iOS
//             ? _buildCupertinoTabScaffold()
//             : _buildMaterialTabScaffold(),
//       ),
//     );
//   }

//   Widget _buildCupertinoTabScaffold() {
//     return CupertinoTabScaffold(
//       tabBar: CupertinoTabBar(
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(CupertinoIcons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(CupertinoIcons.search),
//             label: 'Search',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(CupertinoIcons.heart),
//             label: 'Favorites',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(CupertinoIcons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//       tabBuilder: (context, index) {
//         return CupertinoTabView(
//           builder: (context) {
//             return Stack(
//               children: [
//                 CupertinoPageScaffold(
//                   navigationBar: CupertinoNavigationBar(
//                     middle: Text("I'm a NavBar"),
//                     leading: CupertinoButton(
//                       padding: EdgeInsets.zero,
//                       child: Icon(CupertinoIcons.line_horizontal_3),
//                       onPressed: () {},
//                     ),
//                   ),
//                   child: _getTabContent(index),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildMaterialTabScaffold() {
//     return DefaultTabController(
//       length: 4,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("I'm an AppBar."),
//           bottom: const TabBar(tabs: [
//             Tab(icon: Icon(Icons.home), text: 'Home'),
//             Tab(icon: Icon(Icons.search), text: 'Search'),
//             Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
//             Tab(icon: Icon(Icons.person), text: 'Profile'),
//           ]),
//         ),
//         body: TabBarView(
//           children: List.generate(4, (index) => _getTabContent(index)),
//         ),
//         drawer: Drawer(child: Center(child: Text("I'm a drawer."))),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {},
//           child: Icon(Icons.ac_unit),
//         ),
//       ),
//     );
//   }

//   Widget _getTabContent(int index) {
//     switch(index) {
//       case 0: return Center(child: Text('Home Tab Content'));
//       case 1: return Center(child: Text('Search Tab Content'));
//       case 2: return Center(child: Text('Favorites Tab Content'));
//       case 3: return Center(child: Text('Profile Tab Content'));
//       default: return Center(child: Text('Tab Content'));
//     }
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => MyAppState(),
//       child: MaterialApp(
//           home: DefaultTabController(
//             length: 4,
//             child: Scaffold(  // Wrap Scaffold with MaterialApp
//               appBar: AppBar(
//                 title: Text("I'm aan AppBar."),
//                 bottom: const TabBar(tabs: [
//                   Tab(icon: Icon(Icons.home), text: 'Home'),
//                   Tab(icon: Icon(Icons.search), text: 'Search'),
//                   Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
//                   Tab(icon: Icon(Icons.person), text: 'Profile'),
//                 ]),
//               ),
//               body: TabBarView(
//                 children: [
//                   // Replace these with your actual content widgets
//                   Center(child: Text('Home Tab Content')),
//                   Center(child: Text('Search Tab Content')),
//                   Center(child: Text('Favorites Tab Content')),
//                   Center(child: Text('Profile Tab Content')),
//                 ],
//               ),
//               floatingActionButton: FloatingActionButton(
//                 onPressed: () {},
//                 child: Icon(Icons.ac_unit),
//               ),
//               drawer: Drawer(
//                 child: Center(child: Text("I'm a drawer.")),
//               ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => MyAppState(),
//       child: CupertinoApp(  // 改用CupertinoApp
//         home: CupertinoTabScaffold(  // iOS风格的Tab框架
//           tabBar: CupertinoTabBar(
//             items: const [
//               BottomNavigationBarItem(
//                 icon: Icon(CupertinoIcons.home),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(CupertinoIcons.search),
//                 label: 'Search',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(CupertinoIcons.heart),
//                 label: 'Favorites',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(CupertinoIcons.person),
//                 label: 'Profile',
//               ),
//             ],
//           ),
//           tabBuilder: (context, index) {
//             return CupertinoTabView(
//               builder: (context) {
//                 // 返回对应索引的页面
//                 switch (index) {
//                   case 0:
//                     return const Center(child: Text('Home Page'));
//                   case 1:
//                     return const Center(child: Text('Search Page'));
//                   case 2:
//                     return const Center(child: Text('Favorites Page'));
//                   case 3:
//                     return const Center(child: Text('Profile Page'));
//                   default:
//                     return const Center(child: Text('Page'));
//                 }
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
        body: SafeArea(
      child: Column(
        spacing: 20,
        children: [
          Text('A random AWESOME idea:'),
          Text(appState.current.asLowerCase),
          ElevatedButton(
            onPressed: () {
              print('button pressed!');
            },
            child: Text('Next'),
          ),
          Playground(),
        ],
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const appTitle = 'Form Validation Demo';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
          appBar: AppBar(
            title: Text(appTitle),
          ),
          body: SingleChildScrollView(
            child: ValidationDemo(),
          )),
    );
  }
}

class ValidationDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ValidationDemoState();
  }
}

class ValidationDemoState extends State<ValidationDemo> {
// Note: This is a GlobalKey<FormState>, not a GlobalKey<ValidationDemoState>!
  final _formKey = GlobalKey<FormState>();
// Declare a default bool variable isPasswordVisible and initialize to false.
// This is the default state of the password visibilty.
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.0),
      child: Form(
        key: _formKey, // Set the _formKey here
        child: formUI(), // Set your custom widget here
      ),
    );
  }

// Build a custom widget for your app
  Widget formUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        TextFormField(
          decoration: const InputDecoration(
              labelText:
                  'Username'), // Create an optional decoration for your TextFormField
          validator: _validateUsername,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Email'),
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        TextFormField(
          keyboardType: TextInputType.text,
          validator: _validatePassword,
          obscureText: isPasswordVisible, //This will obscure text dynamically
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            // Here is key idea
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed: () {
                // Update the state i.e. toogle the state of passwordVisible variable
                setState(() {
                  isPasswordVisible
                      ? isPasswordVisible = false
                      : isPasswordVisible = true;
                });
              },
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Processing data')));
                }
              },
              child: const Text('Submit'),
            ))
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email field cannot be empty!';
    }
    // Regex for email validation
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = RegExp(p);
    if (regExp.hasMatch(value)) {
      return null;
    }
    return 'Email provided isn\'t valid.Try another email address';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password field cannot be empty';
    }

    if (value.length < 6) {
      return 'Password length must be greater than 6';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }

    if (value.length < 6) {
      return 'Username length must be greater than 6';
    }
    return null;
  }
}
