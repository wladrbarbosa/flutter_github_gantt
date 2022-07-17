import 'package:flutter/foundation.dart';
import 'package:flutter_github_gantt/model/assignees.dart';
import 'package:flutter_github_gantt/model/label.dart';
import 'package:flutter_github_gantt/model/milestone.dart';
import 'package:flutter_github_gantt/model/reaction.dart';

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

    if (notify) {
      update();
    }
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
		user = json['user'] != null ? Assignee.fromJson(json['user']) : null;
		if (json['labels'] != null) {
			labels = <Label>[];
			json['labels'].forEach((v) { labels!.add(Label.fromJson(v)); });
		}
		state = json['state'];
		locked = json['locked'];
		assignee = json['assignee'] != null ? Assignee.fromJson(json['assignee']) : null;
		if (json['assignees'] != null) {
			assignees = <Assignee>[];
			json['assignees'].forEach((v) { assignees!.add(Assignee.fromJson(v)); });
		}
		milestone = json['milestone'] != null ? Milestone.fromJson(json['milestone']) : null;
		comments = json['comments'];
		createdAt = json['created_at'];
		updatedAt = json['updated_at'];
		closedAt = json['closed_at'];
		authorAssociation = json['author_association'];
		activeLockReason = json['active_lock_reason'];
		body = json['body'];
		reactions = json['reactions'] != null ? Reaction.fromJson(json['reactions']) : null;
		timelineUrl = json['timeline_url'];
		performedViaGithubApp = json['performed_via_github_app'] != null ? true : json['performed_via_github_app'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = <String, dynamic>{};
		data['url'] = url;
		data['repository_url'] = repositoryUrl;
		data['labels_url'] = labelsUrl;
		data['comments_url'] = commentsUrl;
		data['events_url'] = eventsUrl;
		data['html_url'] = htmlUrl;
		data['id'] = id;
		data['node_id'] = nodeId;
		data['number'] = number;
		data['title'] = title;
		if (user != null) {
      data['user'] = user!.toJson();
    }
		if (labels != null) {
      data['labels'] = labels!.map((v) => v.toJson()).toList();
    }
		data['state'] = state;
		data['locked'] = locked;
		if (assignee != null) {
      data['assignee'] = assignee!.toJson();
    }
		if (assignees != null) {
      data['assignees'] = assignees!.map((v) => v.toJson()).toList();
    }
		if (milestone != null) {
      data['milestone'] = milestone!.toJson();
    }
		data['comments'] = comments;
		data['created_at'] = createdAt;
		data['updated_at'] = updatedAt;
		data['closed_at'] = closedAt;
		data['author_association'] = authorAssociation;
		data['active_lock_reason'] = activeLockReason;
		data['body'] = body;
		if (reactions != null) {
      data['reactions'] = reactions!.toJson();
    }
		data['timeline_url'] = timelineUrl;
		data['performed_via_github_app'] = performedViaGithubApp;
		return data;
	}
}