import 'package:flutter_github_gantt/Model/Assignees.dart';

class Milestone {
  String? url;
  String? htmlUrl;
  String? labelsUrl;
  int? id;
  String? nodeId;
  int? number;
  String? title;
  String? description;
  Assignee? creator;
  int? openIssues;
  int? closedIssues;
  String? state;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? dueOn;
  DateTime? closedAt;

  Milestone({
    this.url,
    this.htmlUrl,
    this.labelsUrl,
    this.id,
    this.nodeId,
    this.number,
    this.title,
    this.description,
    this.creator,
    this.openIssues,
    this.closedIssues,
    this.state,
    this.createdAt,
    this.updatedAt,
    this.dueOn,
    this.closedAt
  });

  Milestone.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    htmlUrl = json['html_url'];
    labelsUrl = json['labels_url'];
    id = json['id'];
    nodeId = json['node_id'];
    number = json['number'];
    title = json['title'];
    description = json['description'];
    creator =
        json['creator'] != null ? new Assignee.fromJson(json['creator']) : null;
    openIssues = json['open_issues'];
    closedIssues = json['closed_issues'];
    state = json['state'];
    createdAt = json['created_at'] != null ? DateTime.parse(json['created_at']) : null;
    updatedAt = json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null;
    dueOn = json['due_on'] != null ? DateTime.parse(json['due_on']) : null;
    closedAt = json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['html_url'] = this.htmlUrl;
    data['labels_url'] = this.labelsUrl;
    data['id'] = this.id;
    data['node_id'] = this.nodeId;
    data['number'] = this.number;
    data['title'] = this.title;
    data['description'] = this.description;
    if (this.creator != null) {
      data['creator'] = this.creator!.toJson();
    }
    data['open_issues'] = this.openIssues;
    data['closed_issues'] = this.closedIssues;
    data['state'] = this.state;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['due_on'] = this.dueOn;
    data['closed_at'] = this.closedAt;
    return data;
  }
}