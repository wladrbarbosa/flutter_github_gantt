import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/model/assignees.dart';
import 'package:flutter_github_gantt/model/label.dart';
import 'package:flutter_github_gantt/model/milestone.dart';
import 'package:flutter_github_gantt/model/rate_limit.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/gantt_chart_controller.dart';
import '../controller/repo_controller.dart';
import 'log.dart';
import '../model/issue.dart';
import '../model/user.dart';

class GitHubAPI {
  String? userToken;
  String apiCore = 'https://api.github.com';
  String graphQLCore = 'https://api.github.com/graphql';
  bool refreshIssuesList = true;
  int pagesLoaded = 0;

  Future<T> gitHubRequest<T>(String endPoint, {String method = 'GET', Map<String, dynamic>? body}) async {
    String? encodedBody = body == null ? null : json.encode(body);
    Log.netStartShow('$apiCore$endPoint', data: encodedBody);
    Response? response;
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
            body: encodedBody,
          );
        break;
        case 'POST':
          response = await post(
            Uri.parse('$apiCore$endPoint'),
            headers: {
              HttpHeaders.acceptHeader: 'application/json',
              HttpHeaders.acceptLanguageHeader: 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
              HttpHeaders.authorizationHeader: 'Bearer $userToken',
            },
            body: encodedBody,
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

      if (T.toString() == 'List<dynamic>') {
        result = [] as T;
      } else {
        result = {} as T;
      }
    }
    Log.netEndShow('$apiCore$endPoint');

    return result!;
  }

  Future<dynamic> gitHubGraphQLQuery(String query) async {
    Log.netStartShow(graphQLCore, data: query);
    Response? response;
    Map<String, dynamic>? result;

    try {
      response = await post(
        Uri.parse(graphQLCore),
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
    Log.netEndShow(graphQLCore);

    return result!;
  }

  Future<void> awaitIssuesPages(int totalPages) async {
    if (pagesLoaded < totalPages) {
      Log.show('d', ' $pagesLoaded páginas carregadas de $totalPages. Aguardando 500 ms para continuar...');
      return await Future.delayed(const Duration(milliseconds: 500), () async => await awaitIssuesPages(totalPages));
    }
  }

  Future<void> deleteSelectedIssues() async {
    for (int i = 0; i < GanttChartController.instance.selectedIssues.length; i++) {
      await gitHubGraphQLQuery("mutation {deleteIssue(input:{issueId:\"${GanttChartController.instance.selectedIssues[i]!.nodeId}\"}){repository {name}}}");
    }
    reloadIssues();
  }

  Future<List<Issue>> getIssuesList() async {
    getRateLimit();
    Map<String, dynamic>? resultTotalIssues = await gitHubGraphQLQuery("query {repository(owner:\"${GanttChartController.instance.repo!.owner!.login}\",name:\"${GanttChartController.instance.repo!.name}\"){issues {totalCount}}}");
    int numberOfPages = 0;
    List<Issue> responseLits = [];
    DateTime? chartStart;
    DateTime? chartEnd;
    pagesLoaded = 0;

    if (resultTotalIssues != null) {
      numberOfPages = (resultTotalIssues['data']['repository']['issues']['totalCount'] / 100 as double).ceil();
    }

    for (int j = 1; j <= numberOfPages; j++) {
      gitHubRequest<List<dynamic>>('/repos/${GanttChartController.instance.repo!.owner!.login}/${GanttChartController.instance.repo!.name}/issues?page=$j&per_page=100&state=all&time=${DateTime.now()}').then((issuesList) {
        for (int i = 0; i < issuesList.length; i++) {
          DateTime? startTime;
          DateTime? endTime;

          String startDate = RegExp(r'(?<=start_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=start_date: )\d+\/\d+\/\d+').stringMatch(issuesList[i]['body'] ?? '') ?? DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
          String dueDate = RegExp(r'(?<=due_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=due_date: )\d+\/\d+\/\d+').stringMatch(issuesList[i]['body'] ?? '') ?? DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());

          try {
            startTime = DateFormat('yyyy/M/d${startDate.contains(':') ? ' HH:mm:ss' : ''}').parse(startDate);
            endTime = DateFormat('yyyy/M/d${dueDate.contains(':') ? ' HH:mm:ss' : ''}').parse(dueDate);
          } catch (e) {
            try {
              startTime = DateFormat('yyyy/MM/dd${startDate.contains(':') ? ' HH:mm:ss' : ''}').parse(startDate);
              endTime = DateFormat('yyyy/MM/dd${dueDate.contains(':') ? ' HH:mm:ss' : ''}').parse(dueDate);  
            } catch (e) {
              startTime = DateTime.now();
              endTime = DateTime.now();
            }
          }

          if (chartStart == null) {
            chartStart = startTime;
          } else if (startTime.isBefore(chartStart!)) {
            chartStart = startTime;
          }

          if (chartEnd == null) {
            chartEnd = endTime;
          } else if (endTime.isAfter(chartEnd!)) {
            chartEnd = endTime;
          }

          DateTime fromDate = chartStart!.subtract(const Duration(days: 5));
          GanttChartController.instance.fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
          DateTime toDate = chartEnd!.add(const Duration(days: 5));
          GanttChartController.instance.toDate = DateTime(toDate.year, toDate.month, toDate.day);
          GanttChartController.instance.viewRange = GanttChartController.instance.calculateNumberOfColumnsBetween(
            GanttChartController.instance.fromDate!,
            GanttChartController.instance.toDate!
          );

          Issue temp = Issue.fromJson(issuesList[i], pStartTime: startTime, pEndTime: endTime);
          responseLits.add(temp);
        }
        pagesLoaded++;
      });
    }

    await awaitIssuesPages(numberOfPages);

    refreshIssuesList = false;
    return responseLits;
  }
  
  void reloadIssues() {
    Future.delayed(const Duration(seconds: 1), () {
      GanttChartController.instance.gitHub!.refreshIssuesList = true;
      GanttChartController.instance.repo!.update();
    });
  }

  Future<List<Assignee>> createIssue(String title, String body, int? milestone, List<String> assignees, List<String> labels, {bool isClosed = false}) async {
    List<Assignee> responseList = [];

    gitHubRequest<Map<String, dynamic>>(
      '/repos/${GanttChartController.instance.repo!.owner!.login}/${GanttChartController.instance.repo!.name}/issues?time=${DateTime.now()}',
      method: 'POST',
      body: {
        'title': title,
        'body': body,
        'milestone': milestone,
        'assignees': assignees,
        'labels': labels,
        'state': isClosed ? 'closed' : 'open'
      }
    );

    reloadIssues();
    return responseList;
  }

  Future<void> updateIssue(String title, String body, int? milestone, List<Assignee> assignees, List<Label> labels, List<int> dependencies, {bool isClosed = false}) async {
    GanttChartController.instance.selectedIssues[0]!.toggleProcessing();
    gitHubRequest<Map<String, dynamic>>(
      '/repos/${GanttChartController.instance.repo!.owner!.login}/${GanttChartController.instance.repo!.name}/issues/${GanttChartController.instance.selectedIssues[0]!.number}?time=${DateTime.now()}',
      method: 'PATCH',
      body: {
        'title': title,
        'body': body,
        'milestone': milestone,
        'assignees': assignees.map<String>((e) => e.login!).toList(),
        'labels': labels.map<String>((e) => e.name!).toList(),
        'state': isClosed ? 'closed' : 'open'
      }
    ).then((value) {
      GanttChartController.instance.selectedIssues[0]!.dependencies = dependencies;
      GanttChartController.instance.selectedIssues[0]!.body = body;
      DateTimeRange periodoDaTarefa = GanttChartController.parseIssueBody(GanttChartController.instance.selectedIssues[0]!);
      GanttChartController.instance.selectedIssues[0]!.startTime = periodoDaTarefa.start;
      GanttChartController.instance.selectedIssues[0]!.endTime = periodoDaTarefa.end;
      GanttChartController.instance.selectedIssues[0]!.assignees = assignees;
      GanttChartController.instance.selectedIssues[0]!.labels = labels;
      Issue temp = Issue.fromJson(
        value,
        pStartTime: GanttChartController.instance.selectedIssues[0]!.startTime,
        pEndTime: GanttChartController.instance.selectedIssues[0]!.endTime,
      );
      GanttChartController.instance.selectedIssues[0]!.state = temp.state;
      GanttChartController.instance.selectedIssues[0]!.value = temp.value;
      GanttChartController.instance.selectedIssues[0]!.toggleProcessing();
    });
  }

  Future<void> changeSelectedIssuesState() async {
    for (int i = 0; i < GanttChartController.instance.selectedIssues.length; i++) {
      GanttChartController.instance.selectedIssues[i]!.toggleProcessing();

      gitHubRequest<Map<String, dynamic>>(
        '/repos/${GanttChartController.instance.repo!.owner!.login}/${GanttChartController.instance.repo!.name}/issues/${GanttChartController.instance.selectedIssues[i]!.number}?time=${DateTime.now()}',
        method: 'PATCH',
        body: {
          'state': GanttChartController.instance.selectedIssues[i]!.state == 'open' ? 'closed' : 'open',
        }
      ).then((value) {
        GanttChartController.instance.selectedIssues[i]!.toggleProcessing();
        GanttChartController.instance.selectedIssues[i]!.state = Issue.fromJson(value).state;
        GanttChartController.instance.selectedIssues[i]!.update();
      });
    }
  }

  Future<List<Milestone>> getRepoMilestonesList() async {
    List<Milestone> responseList = [];

    gitHubRequest<List<dynamic>>('/repos/${GanttChartController.instance.repo!.owner!.login}/${GanttChartController.instance.repo!.name}/milestones?state=all&time=${DateTime.now()}').then((milestoneListFuture) {
      for (int i = 0; i < milestoneListFuture.length; i++) {
        responseList.add(Milestone.fromJson(milestoneListFuture[i]));
      }
    });

    return responseList;
  }

  Future<List<Assignee>> getRepoassigneesListFuture() async {
    List<Assignee> responseList = [];

    gitHubRequest<List<dynamic>>('/repos/${GanttChartController.instance.repo!.owner!.login}/${GanttChartController.instance.repo!.name}/assignees?time=${DateTime.now()}').then((assigneesListFuture) {
      for (int i = 0; i < assigneesListFuture.length; i++) {
        responseList.add(Assignee.fromJson(assigneesListFuture[i]));
      }
    });

    return responseList;
  }

  Future<List<Label>> getRepolabelsListFuture() async {
    List<Label> responseList = [];

    gitHubRequest<List<dynamic>>('/repos/${GanttChartController.instance.repo!.owner!.login}/${GanttChartController.instance.repo!.name}/labels?time=${DateTime.now()}').then((labelsListFuture) {
      for (int i = 0; i < labelsListFuture.length; i++) {
        responseList.add(Label.fromJson(labelsListFuture[i]));
      }
    });

    return responseList;
  }

  Future<List<RepoController>> getReposList() async {
    List<dynamic> reposList = await gitHubRequest<List<dynamic>>('/user/repos?per_page=100&time=${DateTime.now()}');
    List<RepoController> responseLits = [];

    for (int i = 0; i < reposList.length; i++) {
      responseLits.add(RepoController.fromJson(reposList[i]));
    }

    GanttChartController.instance.reposList = responseLits;
    return responseLits;
  }

  Future<User?> getUser(TextEditingController tokenController, void Function() rootSetState) async {
    await SharedPreferences.getInstance().then((value) {
      GanttChartController.instance.prefs = value;
      String? savedToken = GanttChartController.instance.prefs!.getString('token');
      String? savedRepo = GanttChartController.instance.prefs!.getString('repo');
      tokenController.text = savedToken ?? '';
      GanttChartController.instance.repo = savedRepo != null ? RepoController.fromJSONStr(savedRepo) : null;
      GanttChartController.instance.gitHub!.userToken = tokenController.text;
    });
    
    dynamic user = await gitHubRequest<dynamic>('/user?time=${DateTime.now()}');

    if (user['login'] != null) {
      GanttChartController.instance.user = User(
        name: user['name'],
        email: '', 
        login: user['login'],
      );
      await GanttChartController.instance.gitHub!.getReposList();
    }
    else {
      GanttChartController.instance.user = null;
    }

    rootSetState();
    return GanttChartController.instance.user;
  }

  Future<Issue> updateIssueTime(Issue currentUssue) async {
    if (currentUssue.body != null) {
      currentUssue.body = currentUssue.body!.replaceFirst(RegExp(r'(?<=start_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=start_date: )\d+\/\d+\/\d+'), DateFormat('yyyy/MM/dd HH:mm:ss').format(currentUssue.startTime!));
      currentUssue.body = currentUssue.body!.replaceFirst(RegExp(r'(?<=due_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=due_date: )\d+\/\d+\/\d+'), DateFormat('yyyy/MM/dd HH:mm:ss').format(currentUssue.endTime!));
    }

    dynamic issue = await gitHubRequest<dynamic>('/repos/${GanttChartController.instance.repo!.owner!.login}/${GanttChartController.instance.repo!.name}/issues/${currentUssue.number}', method: 'PATCH', body: {"body": currentUssue.body});
    Issue response;
    DateTime? startTime;
    DateTime? endTime;

    String startDate = RegExp(r'(?<=start_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=start_date: )\d+\/\d+\/\d+').stringMatch(issue['body'] ?? '') ?? DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
    String dueDate = RegExp(r'(?<=due_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=due_date: )\d+\/\d+\/\d+').stringMatch(issue['body'] ?? '') ?? DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());

    try {
      startTime = DateFormat('yyyy/M/d${startDate.contains(':') ? ' HH:mm:ss' : ''}').parse(startDate);
      endTime = DateFormat('yyyy/M/d${dueDate.contains(':') ? ' HH:mm:ss' : ''}').parse(dueDate);
    } catch (e) {
      try {
        startTime = DateFormat('yyyy/MM/dd${startDate.contains(':') ? ' HH:mm:ss' : ''}').parse(startDate);
        endTime = DateFormat('yyyy/MM/dd${dueDate.contains(':') ? ' HH:mm:ss' : ''}').parse(dueDate);  
      } catch (e) {
        startTime = DateTime.now();
        endTime = DateTime.now();
      }
    }

    response = Issue.fromJson(issue, pStartTime: startTime, pEndTime: endTime);

    return response;
  }

  Future<void> getRateLimit() async {
    Map<String, dynamic> response = await gitHubRequest<Map<String, dynamic>>('/rate_limit');
    GanttChartController.instance.rateLimit = RateLimit.fromJson(response);
  }
}