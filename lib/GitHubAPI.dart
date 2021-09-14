import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Controller/GanttChartController.dart';
import 'Controller/RepoController.dart';
import 'Log.dart';
import 'Model/Issue.dart';
import 'Model/User.dart';

class GitHubAPI {
  String? userToken;
  String apiCore = 'https://api.github.com';
  String graphQLCore = 'https://api.github.com/graphql';
  bool refreshIssuesList = true;
  int pagesLoaded = 0;

  Future<T> gitHubGet<T>(String endPoint, {String method = 'GET', Map<String, dynamic>? body}) async {
    Log.netStartShow('$apiCore$endPoint');
    Response response;
    T? result;

    try {
      switch (method) {
        case 'PATCH':
          response = await patch(
            Uri.parse('$apiCore$endPoint'),
            headers: {
              HttpHeaders.acceptHeader: 'application/json',
              HttpHeaders.acceptLanguageHeader: 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
              HttpHeaders.authorizationHeader: 'Bearer $userToken',
            },
            body: body == null ? null : json.encode(body),
          );
        break;
        default:
          response = await get(
            Uri.parse('$apiCore$endPoint'),
            headers: {
              HttpHeaders.acceptHeader: 'application/json',
              HttpHeaders.acceptLanguageHeader: 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
              HttpHeaders.authorizationHeader: 'Bearer $userToken',
            },
          );
      }
      
      result = json.decode(response.body) as T;
    } catch (e) {
      Log.show('e', '$e');

      if (T.toString() == 'List<dynamic>')
        result = [] as T;
      else
        result = {} as T;
    }
    Log.netEndShow('$apiCore$endPoint');

    return result!;
  }

  Future<dynamic> gitHubGraphQLQuery(String query) async {
    Log.netStartShow('$graphQLCore', data: query);
    Response response;
    Map<String, dynamic>? result;

    try {
      response = await post(
        Uri.parse('$graphQLCore'),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.acceptLanguageHeader: 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          HttpHeaders.authorizationHeader: 'Bearer $userToken',
        },
        body: json.encode({
          "query": query
        }),
      );

      result = json.decode(response.body);
    } catch (e) {
      Log.show('e', '$e');
      result = {};
    }
    Log.netEndShow('$graphQLCore');

    return result!;
  }

  Future<void> awaitIssuesPages(int totalPages) async {
    if (pagesLoaded < totalPages) {
      Log.show('d', '$pagesLoaded páginas carregadas de $totalPages. Aguardando 100 ms para continuar...');
      return await Future.delayed(Duration(milliseconds: 100), () async => await awaitIssuesPages(totalPages));
    }
  }

  Future<List<Issue>> getIssuesList() async {
    Map<String, dynamic>? resultTotalIssues = await gitHubGraphQLQuery("query {repository(owner:\"${GanttChartController.instance.user!.login}\",name:\"${GanttChartController.instance.repo!.name}\"){issues {totalCount}}}");
    int numberOfPages = 0;
    List<Issue> responseLits = [];
    DateTime? chartStart;
    DateTime? chartEnd;
    pagesLoaded = 0;

    if (resultTotalIssues != null)
      numberOfPages = (resultTotalIssues['data']['repository']['issues']['totalCount'] / 100 as double).ceil();

    for (int j = 1; j <= numberOfPages; j++) {
      gitHubGet<List<dynamic>>('/repos/${GanttChartController.instance.user!.login}/${GanttChartController.instance.repo!.name}/issues?page=$j&per_page=100&state=all&time=${DateTime.now()}').then((issuesList) {
        for (int i = 0; i < issuesList.length; i++) {
          DateTime? startTime;
          DateTime? endTime;

          try {
            startTime = DateFormat('yyyy/M/d').parse(RegExp(r'(?<=start_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=start_date: )\d+\/\d+\/\d+').stringMatch(issuesList[i]['body'])!);
            endTime = DateFormat('yyyy/M/d').parse(RegExp(r'(?<=due_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=due_date: )\d+\/\d+\/\d+').stringMatch(issuesList[i]['body'])!);
          } catch (e) {
            try {
              startTime = DateFormat('yyyy/MM/dd').parse(RegExp(r'(?<=start_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=start_date: )\d+\/\d+\/\d+').stringMatch(issuesList[i]['body'])!);
              endTime = DateFormat('yyyy/MM/dd').parse(RegExp(r'(?<=due_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=due_date: )\d+\/\d+\/\d+').stringMatch(issuesList[i]['body'])!);  
            } catch (e) {
              startTime = DateTime.now();
              endTime = DateTime.now();
            }
          }

          if (chartStart == null)
            chartStart = startTime;
          else if (startTime.isBefore(chartStart!)) {
            chartStart = startTime;
          }

          if (chartEnd == null)
            chartEnd = endTime;
          else if (endTime.isAfter(chartEnd!)) {
            chartEnd = endTime;
          }

          responseLits.add(Issue(
            title: issuesList[i]['title'],
            startTime: startTime,
            endTime: endTime,
            number: issuesList[i]['number'],
            assignees: (issuesList[i]['assignees'] as List<dynamic>).map<String>((e) => e['login']).toList(),
            state: issuesList[i]['state'],
            body: issuesList[i]['body'],
          ));
        }
        pagesLoaded++;
      });
    }

    await awaitIssuesPages(numberOfPages);

    refreshIssuesList = false;
    GanttChartController.instance.fromDate = chartStart!.subtract(Duration(days: 5));
    GanttChartController.instance.toDate = chartEnd!.add(Duration(days: 5));
    GanttChartController.instance.viewRange = GanttChartController.instance.calculateNumberOfDaysBetween(
      GanttChartController.instance.fromDate!,
      GanttChartController.instance.toDate!
    );
    return responseLits;
  }

  Future<List<RepoController>> getReposList() async {
    List<dynamic> reposList = await gitHubGet<List<dynamic>>('/user/repos?per_page=100&time=${DateTime.now()}');
    List<RepoController> responseLits = [];

    for (int i = 0; i < reposList.length; i++) {
      responseLits.add(RepoController(
        id: reposList[i]['id'],
        name: reposList[i]['name'],
      ));
    }

    GanttChartController.instance.reposList = responseLits;
    return responseLits;
  }

  Future<User?> getUser(TextEditingController tokenController, void Function() rootSetState) async {
    await SharedPreferences.getInstance().then((value) {
      GanttChartController.instance.prefs = value;
      String? savedToken = GanttChartController.instance.prefs!.getString('token');
      String? savedRepo = GanttChartController.instance.prefs!.getString('repo');
      tokenController.text = savedToken != null ? savedToken : '';
      GanttChartController.instance.repo = savedRepo != null ? RepoController.fromJSONStr(savedRepo) : null;
      GanttChartController.instance.gitHub!.userToken = tokenController.text;
    });
    
    dynamic user = await gitHubGet<dynamic>('/user?time=${DateTime.now()}');

    if (user['login'] != null) {
      GanttChartController.instance.user = User(
        name: user['name'],
        email: '', 
        login: user['login'],
      );
      await GanttChartController.instance.gitHub!.getReposList();
    }
    else
      GanttChartController.instance.user = null;

    rootSetState();
    return GanttChartController.instance.user;
  }

  Future<Issue> updateIssueTime(Issue currentUssue) async {
    if (currentUssue.body != null) {
      currentUssue.body = currentUssue.body!.replaceFirst(RegExp(r'(?<=start_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=start_date: )\d+\/\d+\/\d+'), DateFormat('yyyy/MM/dd').format(currentUssue.startTime!));
      currentUssue.body = currentUssue.body!.replaceFirst(RegExp(r'(?<=due_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=due_date: )\d+\/\d+\/\d+'), DateFormat('yyyy/MM/dd').format(currentUssue.endTime!));
    }

    dynamic issue = await gitHubGet<dynamic>('/repos/${GanttChartController.instance.user!.login}/${GanttChartController.instance.repo!.name}/issues/${currentUssue.number}', method: 'PATCH', body: {"body": currentUssue.body});
    Issue response;
    DateTime? startTime;
    DateTime? endTime;

    try {
      startTime = DateFormat('yyyy/M/d').parse(RegExp(r'(?<=start_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=start_date: )\d+\/\d+\/\d+').stringMatch(issue['body'])!);
      endTime = DateFormat('yyyy/M/d').parse(RegExp(r'(?<=due_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=due_date: )\d+\/\d+\/\d+').stringMatch(issue['body'])!);
    } catch (e) {
      try {
        startTime = DateFormat('yyyy/MM/dd').parse(RegExp(r'(?<=start_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=start_date: )\d+\/\d+\/\d+').stringMatch(issue['body'])!);
        endTime = DateFormat('yyyy/MM/dd').parse(RegExp(r'(?<=due_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=due_date: )\d+\/\d+\/\d+').stringMatch(issue['body'])!);  
      } catch (e) {
        startTime = DateTime.now();
        endTime = DateTime.now();
      }
    }

    response = Issue(
      title: issue['title'],
      startTime: startTime,
      endTime: endTime,
      number: issue['number'],
      assignees: (issue['assignees'] as List<dynamic>).map<String>((e) => e['login']).toList(),
      state: issue['state'],
      body: issue['body'],
      selected: currentUssue.selected,
    );

    return response;
  }
}