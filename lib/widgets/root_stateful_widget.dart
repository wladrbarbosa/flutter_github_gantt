import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/configs.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/controller/repos_controller.dart';
import 'package:flutter_github_gantt/controller/repository.dart';
import 'package:flutter_github_gantt/widgets/repo_widget.dart';
import 'package:flutter_github_gantt/externals/github_api.dart';
import 'package:flutter_github_gantt/model/user.dart';
import 'package:flutter_github_gantt/widgets/fgc_text_field.dart';
import 'package:flutter_github_gantt/widgets/update_button.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';

class RootStatefulWidget extends StatefulWidget {
  const RootStatefulWidget({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  RootStatefulWidgetState createState() => RootStatefulWidgetState();
}

class RootStatefulWidgetState extends State<RootStatefulWidget> {
  final TextEditingController _userToken = TextEditingController();
  Future<User?>? _user;
  bool touchMoves = false;

  void update() {
    setState((){
    });
  }

  @override
  void initState() {
    super.initState();
    GanttChartController.instance.initialize();
    GanttChartController.instance.focus = FocusNode(debugLabel: 'Button');
    GanttChartController.instance.refreshFocusAttachment(context);
    GanttChartController.instance.gitHub = GitHubAPI();
    _user = GanttChartController.instance.gitHub!.getUser(_userToken, update);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    if (GoRouterState.of(context).location == '/') {
      GanttChartController.instance.focus.requestFocus();
    }

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
                const UpdateButton(),
                TextButton(
                  onPressed: () async {
                    context.go('/about');
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
                FGCTextField(
                  _userToken,
                  'Personal token',
                  'Personal token',
                  obscureText: true,
                  onChanged: (value) async {
                    await GanttChartController.instance.prefs!.setString('token', value);
                    GanttChartController.instance.gitHub!.userToken = value;
                    _user = GanttChartController.instance.gitHub!.getUser(_userToken, update);
                  },
                ),
                Wrap(
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Repos:'
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      width: 600,
                      child: GestureDetector(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) {
                              return  Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: mediaQuery.size.width / 10,
                                  vertical: mediaQuery.size.height / 10,
                                ),
                                child: MultiSelectDialog<int>(
                                  cancelText: const Text(
                                    'Cancelar'
                                  ),
                                  confirmText: const Text(
                                    'Confirmar'
                                  ),
                                  selectedColor: Theme.of(context).primaryColor,
                                  unselectedColor: Colors.white,
                                  searchHint: 'Pesquisar',
                                  title: const Text('Pesquisar'),
                                  itemsTextStyle: const TextStyle(color: Colors.white),
                                  checkColor: Theme.of(context).primaryColor,
                                  selectedItemsTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                                  items: ReposController.repos.map<MultiSelectItem<int>>((e) {
                                    return MultiSelectItem<int>(
                                      e.id!,
                                      e.name!,
                                    );
                                  }).toList(),
                                  initialValue: GanttChartController.selRepos.map<int>((e) => e.id!).toList(),
                                  onConfirm: (values) {
                                    List<Repository> newSelection = ReposController.repos.where((el) => values.contains(el.id)).toList();

                                    if (GanttChartController.selRepos != newSelection) {
                                      setState(() {
                                        GanttChartController.instance.gitHub!.reloadIssues();
                                        GanttChartController.instance.isTodayJumped = false;
                                        GanttChartController.selRepos = newSelection;
                                        GanttChartController.instance.prefs!.setString('repos', Repository.listToJSONStr(GanttChartController.selRepos));
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 40,
                          color: Colors.transparent,
                          child: GanttChartController.selRepos.isNotEmpty ? MultiSelectChipDisplay<Repository>(
                            height: 40,
                            scroll: true,
                            textStyle: const TextStyle(color: Colors.white),
                            colorator: (repo) {
                              return ReposController.getRepoColorById(repo.nodeId!);
                            },
                            onTap: (repo) async{
                              context.go('/repoConfig/${repo.nodeId!}');
                            },
                            items: GanttChartController.selRepos.map<MultiSelectItem<Repository>>((e) {
                              return MultiSelectItem<Repository>(
                                e,
                                e.name!,
                              );
                            }).toList(),
                          ) : const Center(
                            child: Text(
                              'Clique aqui para selecionar repositórios...'
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                FGCTextField(
                  GanttChartController.instance.filterController,
                  'Filtrar por título',
                  'Filtro...',
                  onChanged: (value) async {
                    GanttChartController.instance.listStorageKey = PageStorageKey('list$value');
                    GanttChartController.reposController.update();
                  },
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
                      return ChangeNotifierProvider<ReposController?>.value(
                        value: GanttChartController.reposController,
                        child: Consumer<ReposController?>(
                          builder: (repoContext, repoValue, child) {
                            Configs.initializeConfigs();

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: RepoWidget(
                                repos: GanttChartController.selRepos.map<String>((e) => e.name!).toList(),
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