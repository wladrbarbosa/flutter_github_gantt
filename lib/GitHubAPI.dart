import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'Controller/GanttChartController.dart';
import 'Controller/RepoController.dart';
import 'Log.dart';
import 'Model/Issue.dart';
import 'Model/User.dart';

class GitHubAPI {
  String? userToken;
  String apiCore = 'https://api.github.com';
  bool refreshIssuesList = true;

  Future<T> gitHubGet<T>(String endPoint, {String method = 'GET', Map<String, dynamic>? body}) async {
    Log.netStartShow('$apiCore$endPoint');
    Response response;

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
    
    T result = json.decode(response.body) as T;
    Log.netEndShow('$apiCore$endPoint');

    return result;
  }

  Future<List<Issue>> getIssuesList() async {
    List<dynamic> issuesList = await gitHubGet<List<dynamic>>('/repos/${GanttChartController.instance.user!.login}/${GanttChartController.instance.repo!.name}/issues?per_page=100&state=all&time=${DateTime.now()}');
    List<Issue> responseLits = [];
    DateTime? chartStart;
    DateTime? chartEnd;

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
      else if (startTime.isBefore(chartStart)) {
        chartStart = startTime;
      }

      if (chartEnd == null)
        chartEnd = endTime;
      else if (endTime.isAfter(chartEnd)) {
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
    List<dynamic> reposList = await gitHubGet<List<dynamic>>('/users/${GanttChartController.instance.user!.login}/repos?per_page=100&state=all&time=${DateTime.now()}');
    List<RepoController> responseLits = [];

    for (int i = 0; i < reposList.length; i++) {
      responseLits.add(RepoController(
        name: reposList[i]['name'],
      ));
    }

    GanttChartController.instance.reposList = responseLits;
    return responseLits;
  }

  Future<void> getUser() async {
    dynamic user = await gitHubGet<dynamic>('/user?time=${DateTime.now()}');

    GanttChartController.instance.user = User(
      name: user['name'],
      email: '', 
      login: user['login'],
    );
  }

  Future<Issue> updateIssueTime(Issue currentUssue) async {
    currentUssue.body = currentUssue.body.replaceFirst(RegExp(r'(?<=start_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=start_date: )\d+\/\d+\/\d+'), DateFormat('yyyy/MM/dd').format(currentUssue.startTime!));
    currentUssue.body = currentUssue.body.replaceFirst(RegExp(r'(?<=due_date: )\d+\/\d+\/\d+ \d+:\d+:\d+|(?<=due_date: )\d+\/\d+\/\d+'), DateFormat('yyyy/MM/dd').format(currentUssue.endTime!));

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