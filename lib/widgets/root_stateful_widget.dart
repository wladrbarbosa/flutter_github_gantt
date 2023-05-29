import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/configs.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/controller/repo_controller.dart';
import 'package:flutter_github_gantt/widgets/repo_widget.dart';
import 'package:flutter_github_gantt/externals/github_api.dart';
import 'package:flutter_github_gantt/model/user.dart';
import 'package:flutter_github_gantt/view/about_view.dart';
import 'package:flutter_github_gantt/widgets/fgc_text_field.dart';
import 'package:flutter_github_gantt/widgets/update_button.dart';
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
                const UpdateButton(),
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
                        disabledHint: const Text(
                          'Selecione o repositório...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                FGCTextField(
                  GanttChartController.instance.filterController,
                  'Filtrar por título',
                  'Filtro...',
                  onChanged: (value) async {
                    GanttChartController.instance.repo!.update();
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
                      return ChangeNotifierProvider<RepoController?>.value(
                        value: GanttChartController.instance.repo,
                        child: Consumer<RepoController?>(
                          builder: (repoContext, repoValue, child) {
                            Configs.initializeConfigs();

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: RepoWidget(
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