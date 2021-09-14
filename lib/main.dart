import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/Controller/GanttChartController.dart';
import 'package:provider/provider.dart';
import 'Controller/RepoController.dart';
import 'GanttChartApp.dart';
import 'GitHubAPI.dart';
import 'Model/User.dart';

void main() {
  runApp(MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => { 
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Github Gantt',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
        primarySwatch: Colors.green,
      ),
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Github Gantt'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _userToken = TextEditingController();
  Future<User?>? _user;

  void update() {
    setState((){
    });
  }

  @override
  void initState() {
    super.initState();
    GanttChartController.instance.initialize();
    GanttChartController.instance.gitHub = GitHubAPI();
    _user = GanttChartController.instance.gitHub!.getUser(_userToken, update);
  }

  @override
  Widget build(BuildContext context) {
    GanttChartController.instance.setContext(context, MediaQuery.of(context).size.width / 4);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    child: TextField(
                      controller: _userToken,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Personal token'
                      ),
                      onChanged: (value) async {
                        await GanttChartController.instance.prefs!.setString('token', value);
                        GanttChartController.instance.gitHub!.userToken = value;
                        _user = GanttChartController.instance.gitHub!.getUser(_userToken, update);
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container()
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: DropdownButton<int>(
                            value: GanttChartController.instance.repo == null ? null : GanttChartController.instance.repo!.id,
                            onChanged: (newValue) {
                              setState(() {
                                GanttChartController.instance.repo = GanttChartController.instance.reposList.singleWhereOrNull((e) => e.id == newValue);
                                GanttChartController.instance.prefs!.setString('repo', GanttChartController.instance.repo!.toJSONStr());
                              });
                            },
                            hint: Text(
                              'Selecione o repositório...',
                            ),
                            items: GanttChartController.instance.reposList.map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                              child: Text(e.name!),
                              value: e.id,
                            )).toList()
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextButton(
                          onPressed: () {
                            GanttChartController.instance.gitHub!.refreshIssuesList = true;
                            GanttChartController.instance.repo!.update();
                          },
                          child: Text(
                            'Atualizar',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FutureBuilder<User?>(
          future: _user,
          builder: (userContext, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.done) {
              if (userSnapshot.hasData)
                return ChangeNotifierProvider<RepoController?>.value(
                  value: GanttChartController.instance.repo,
                  child: Consumer<RepoController?>(
                    builder: (repoContext, repoValue, child) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: GanttChartApp(
                          repo: repoValue != null ? repoValue.name : '',
                          token: _userToken.text,
                        ),
                      );
                    }
                  ),
                );
              else
                return Center(
                  child: Text(
                    'Token inexistente ou incorreta'
                  ),
                );
            }
            else
              return Center(
                child: CircularProgressIndicator()
              );
          }
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
