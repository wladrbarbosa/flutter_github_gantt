import 'package:flutter/foundation.dart';
import 'package:flutter_github_gantt/Model/Assignees.dart';
import 'package:flutter_github_gantt/Model/Label.dart';
import 'package:flutter_github_gantt/Model/Milestone.dart';
import 'package:flutter_github_gantt/Model/Reaction.dart';

class Issue extends ChangeNotifier {
  Issue({
    this.url,
    this.repositoryUrl,
    this.labelsUrl,
    this.commentsUrl,
    this.eventsUrl,
    this.htmlUrl,
    this.id,
    this.nodeId,
    this.number,
    this.title,
    this.user,
    this.labels,
    this.state,
    this.locked,
    this.assignee,
    this.assignees,
    this.milestone,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.closedAt,
    this.authorAssociation,
    this.activeLockReason,
    this.body,
    this.reactions,
    this.timelineUrl,
    this.performedViaGithubApp,
    this.selected = false,
    this.processing = false,
    this.dragPosFactor = 0,
    this.draggingRemainingWidth,
    this.startPanChartPos = 0,
    this.remainingWidth,
    this.startTime,
    this.endTime,
    this.dependencies = const [],
  });

  String? url;
	String? repositoryUrl;
	String? labelsUrl;
	String? commentsUrl;
	String? eventsUrl;
	String? htmlUrl;
	int? id;
	String? nodeId;
	int? number;
	String? title;
	Assignee? user;
	List<Label>? labels;
	String? state;
	bool? locked;
	Assignee? assignee;
	List<Assignee>? assignees;
	Milestone? milestone;
	int? comments;
	String? createdAt;
	String? updatedAt;
	String? closedAt;
	String? authorAssociation;
	String? activeLockReason;
	String? body;
	Reaction? reactions;
	String? timelineUrl;
	bool? performedViaGithubApp;
  double _width = 0;
  bool selected = false;
  bool processing = false;
  double dragPosFactor = 0;
  int? draggingRemainingWidth;
  int? remainingWidth;
  double startPanChartPos = 0;
  DateTime? startTime = DateTime.now();
  DateTime? endTime = DateTime.now();
  List<int> dependencies = [];

  double get width => _width;
  set width(double value) {
    _width = value;
    update();
  }

  void update() {
    notifyListeners();
  }

  void toggleSelect() {
    selected = !selected; 
    update();
  }

  void toggleProcessing({bool notify = true}) {
    processing = !processing;

    if (notify)
      update();
  }

  Issue.fromJson(Map<String, dynamic> json) {
		url = json['url'];
		repositoryUrl = json['repository_url'];
		labelsUrl = json['labels_url'];
		commentsUrl = json['comments_url'];
		eventsUrl = json['events_url'];
		htmlUrl = json['html_url'];
		id = json['id'];
		nodeId = json['node_id'];
		number = json['number'];
		title = json['title'];
		user = json['user'] != null ? new Assignee.fromJson(json['user']) : null;
		if (json['labels'] != null) {
			labels = <Label>[];
			json['labels'].forEach((v) { labels!.add(new Label.fromJson(v)); });
		}
		state = json['state'];
		locked = json['locked'];
		assignee = json['assignee'] != null ? new Assignee.fromJson(json['assignee']) : null;
		if (json['assignees'] != null) {
			assignees = <Assignee>[];
			json['assignees'].forEach((v) { assignees!.add(new Assignee.fromJson(v)); });
		}
		milestone = json['milestone'] != null ? new Milestone.fromJson(json['milestone']) : null;
		comments = json['comments'];
		createdAt = json['created_at'];
		updatedAt = json['updated_at'];
		closedAt = json['closed_at'];
		authorAssociation = json['author_association'];
		activeLockReason = json['active_lock_reason'];
		body = json['body'];
		reactions = json['reactions'] != null ? new Reaction.fromJson(json['reactions']) : null;
		timelineUrl = json['timeline_url'];
		performedViaGithubApp = json['performed_via_github_app'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['url'] = this.url;
		data['repository_url'] = this.repositoryUrl;
		data['labels_url'] = this.labelsUrl;
		data['comments_url'] = this.commentsUrl;
		data['events_url'] = this.eventsUrl;
		data['html_url'] = this.htmlUrl;
		data['id'] = this.id;
		data['node_id'] = this.nodeId;
		data['number'] = this.number;
		data['title'] = this.title;
		if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
		if (this.labels != null) {
      data['labels'] = this.labels!.map((v) => v.toJson()).toList();
    }
		data['state'] = this.state;
		data['locked'] = this.locked;
		if (this.assignee != null) {
      data['assignee'] = this.assignee!.toJson();
    }
		if (this.assignees != null) {
      data['assignees'] = this.assignees!.map((v) => v.toJson()).toList();
    }
		if (this.milestone != null) {
      data['milestone'] = this.milestone!.toJson();
    }
		data['comments'] = this.comments;
		data['created_at'] = this.createdAt;
		data['updated_at'] = this.updatedAt;
		data['closed_at'] = this.closedAt;
		data['author_association'] = this.authorAssociation;
		data['active_lock_reason'] = this.activeLockReason;
		data['body'] = this.body;
		if (this.reactions != null) {
      data['reactions'] = this.reactions!.toJson();
    }
		data['timeline_url'] = this.timelineUrl;
		data['performed_via_github_app'] = this.performedViaGithubApp;
		return data;
	}
}