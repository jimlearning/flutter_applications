import 'package:flutter/material.dart';

class Playground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return Padding(
        padding: EdgeInsets.all(16.0), // 添加16像素的内边距
        child: Container(
          margin: EdgeInsets.all(8.0), // 添加8像素的外边距
          child: Container(  // 使用 Container 来添加背景色
            color: Colors.blue[100], // 设置浅蓝色背景
            child: Column(  // 使用 Column 来垂直排列子元素
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16.0, // 添加16像素的垂直间距,
              children: [
                Icon(Icons.star, size: 50, color: Colors.yellow),
                Icon(Icons.star, size: 50, color: Colors.yellow),
                Icon(Icons.star, size: 50, color: Colors.yellow),
                // 使用 IntrinsicWidth 让 Row 根据内容自适应宽度
                IntrinsicWidth(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      // 使用 FittedBox 让文本自适应宽度
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Baseline',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      // 使用 FittedBox 让文本自适应宽度
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Baseline',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      // 使用 FittedBox 让文本自适应宽度
                      Text(
                          'Baseline',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      Text(
                          'Baseline',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
              ],
            ),
          ),
        )
      );
  }
}

// class Banner extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     Widget main = Scaffold(
//       appBar: AppBar(title: Text('Stack')),
//     );

//     return Stack(
//       fit: StackFit.expand,
//       children: <Widget>[
//         main,
//         Banner(
//           message: "Top Start",
//           location: BannerLocation.topStart,
//         ),
//         Banner(
//           message: "Top End",
//           location: BannerLocation.topEnd,
//         ),
//         Banner(
//           message: "Bottom Start",
//           location: BannerLocation.bottomStart,
//         ),
//         Banner(
//           message: "Bottom End",
//           location: BannerLocation.bottomEnd,
//         ),
//       ],
//     );
//   }
// }

class NavigationBarWithPages extends StatefulWidget {
  const NavigationBarWithPages({super.key});

  @override
  State<NavigationBarWithPages> createState() => _NavigationBarWithPagesState();
}

class _NavigationBarWithPagesState extends State<NavigationBarWithPages> {
  // 存储当前选中的导航项索引
  int _index = 0;

  // 定义页面列表
  final List<Widget> _pages = [
    // 首页
    const Center(
      child: Text('首页内容'),
    ),
    // 搜索页
    const Center(
      child: Text('搜索页内容'),
    ),
    // 个人中心页
    const Center(
      child: Text('个人中心内容'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 根据当前索引显示对应页面
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (newIndex) {
          setState(() {
            _index = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '搜索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class MyHomepage extends StatefulWidget {
  const MyHomepage({super.key});

  @override
  State<MyHomepage> createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _index,
      onTap: (newIndex) {
        setState(() {
          _index = newIndex;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '搜索',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }
}