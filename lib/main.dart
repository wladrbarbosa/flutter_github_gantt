import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/view/about.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'controller/repo_controller.dart';
import 'gantt_chart_app.dart';
import 'github_api.dart';
import 'model/user.dart';

void main() {
  runApp(const MyApp());
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
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'), // Brazillian Portuguese, no country code
        Locale('en', ''), // English, no country code
        Locale('es', ''), // Spanish, no country code
      ],
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Github Gantt',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MyHomePage(title: 'Github Gantt'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final TextEditingController _userToken = TextEditingController();
  Future<User?>? _user;

  void update() {
    setState((){
    });
  }

  @override
  void initState() {
    super.initState();
    GanttChartController.instance.initialize();
    GanttChartController.instance.refreshFocusAttachment(context);
    GanttChartController.instance.gitHub = GitHubAPI();
    _user = GanttChartController.instance.gitHub!.getUser(_userToken, update);
  }

  @override
  Widget build(BuildContext context) {
    if (GanttChartController.instance.rootContext == null) {
      GanttChartController.instance.setContext(context, GanttChartController.instance.issuesListWidth);
    }

    if (MediaQuery.of(context).size.width < GanttChartController.instance.issuesListWidth) {
      GanttChartController.instance.setContext(context, MediaQuery.of(context).size.width);
    }

    GanttChartController.instance.nodeAttachment!.reparent();
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
            width: MediaQuery.of(context).size.width / 2.45,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    GanttChartController.instance.gitHub!.reloadIssues();
                  },
                  child: const Text(
                    'Atualizar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (newIssueDialogContext) {
                        return const About();
                      }
                    );
                  },
                  child: const Icon(
                    Icons.settings,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0
            ),
            child: Wrap(
              spacing: 20,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Token:'
                    ),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: _userToken,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Personal token'
                        ),
                        onChanged: (value) async {
                          await GanttChartController.instance.prefs!.setString('token', value);
                          GanttChartController.instance.gitHub!.userToken = value;
                          _user = GanttChartController.instance.gitHub!.getUser(_userToken, update);
                        },
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Repo:'
                    ),
                    SizedBox(
                      width: 250,
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: GanttChartController.instance.repo == null ? null : GanttChartController.instance.repo!.id,
                        onChanged: (newValue) {
                          setState(() {
                            GanttChartController.instance.repo = GanttChartController.instance.reposList.singleWhereOrNull((e) => e.id == newValue);
                            GanttChartController.instance.prefs!.setString('repo', GanttChartController.instance.repo!.toJSONStr());
                          });
                        },
                        hint: const Text(
                          'Selecione o repositório...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        items: GanttChartController.instance.reposList.map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                          value: e.id,
                          child: Text(
                            e.name!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )).toList()
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Filtrar por título:'
                    ),
                    SizedBox(
                      width: 250,
                      child: TextFormField(
                        controller: GanttChartController.instance.filterController,
                        decoration: const InputDecoration(
                          hintText: 'Filtro...'
                        ),
                        onChanged: (value) async {
                          GanttChartController.instance.repo!.update();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: FutureBuilder<User?>(
                future: _user,
                builder: (userContext, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.done) {
                    if (userSnapshot.hasData) {
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
                    } else {
                      return const Center(
                        child: Text(
                          'Token inexistente ou incorreta'
                        ),
                      );
                    }
                  }
                  else {
                    return const Center(
                      child: CircularProgressIndicator()
                    );
                  }
                }
              ),
            ),
          ),
        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
