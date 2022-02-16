import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_github_gantt/Model/Assignees.dart';
import 'package:flutter_github_gantt/Model/Permission.dart';

class RepoController extends ChangeNotifier {
  RepoController({
    this.id,
    this.nodeId,
    this.name,
    this.fullName,
    this.private,
    this.owner,
    this.htmlUrl,
    this.description,
    this.fork,
    this.url,
    this.forksUrl,
    this.keysUrl,
    this.collaboratorsUrl,
    this.teamsUrl,
    this.hooksUrl,
    this.issueEventsUrl,
    this.eventsUrl,
    this.assigneesUrl,
    this.branchesUrl,
    this.tagsUrl,
    this.blobsUrl,
    this.gitTagsUrl,
    this.gitRefsUrl,
    this.treesUrl,
    this.statusesUrl,
    this.languagesUrl,
    this.stargazersUrl,
    this.contributorsUrl,
    this.subscribersUrl,
    this.subscriptionUrl,
    this.commitsUrl,
    this.gitCommitsUrl,
    this.commentsUrl,
    this.issueCommentUrl,
    this.contentsUrl,
    this.compareUrl,
    this.mergesUrl,
    this.archiveUrl,
    this.downloadsUrl,
    this.issuesUrl,
    this.pullsUrl,
    this.milestonesUrl,
    this.notificationsUrl,
    this.labelsUrl,
    this.releasesUrl,
    this.deploymentsUrl,
    this.createdAt,
    this.updatedAt,
    this.pushedAt,
    this.gitUrl,
    this.sshUrl,
    this.cloneUrl,
    this.svnUrl,
    this.homepage,
    this.size,
    this.stargazersCount,
    this.watchersCount,
    this.language,
    this.hasIssues,
    this.hasProjects,
    this.hasDownloads,
    this.hasWiki,
    this.hasPages,
    this.forksCount,
    this.mirrorUrl,
    this.archived,
    this.disabled,
    this.openIssuesCount,
    this.license,
    this.allowForking,
    this.isTemplate,
    this.topics,
    this.visibility,
    this.forks,
    this.openIssues,
    this.watchers,
    this.defaultBranch,
    this.permissions
  });

  int? id;
  String? nodeId;
  String? name;
  String? fullName;
  bool? private;
  Assignee? owner;
  String? htmlUrl;
  String? description;
  bool? fork;
  String? url;
  String? forksUrl;
  String? keysUrl;
  String? collaboratorsUrl;
  String? teamsUrl;
  String? hooksUrl;
  String? issueEventsUrl;
  String? eventsUrl;
  String? assigneesUrl;
  String? branchesUrl;
  String? tagsUrl;
  String? blobsUrl;
  String? gitTagsUrl;
  String? gitRefsUrl;
  String? treesUrl;
  String? statusesUrl;
  String? languagesUrl;
  String? stargazersUrl;
  String? contributorsUrl;
  String? subscribersUrl;
  String? subscriptionUrl;
  String? commitsUrl;
  String? gitCommitsUrl;
  String? commentsUrl;
  String? issueCommentUrl;
  String? contentsUrl;
  String? compareUrl;
  String? mergesUrl;
  String? archiveUrl;
  String? downloadsUrl;
  String? issuesUrl;
  String? pullsUrl;
  String? milestonesUrl;
  String? notificationsUrl;
  String? labelsUrl;
  String? releasesUrl;
  String? deploymentsUrl;
  String? createdAt;
  String? updatedAt;
  String? pushedAt;
  String? gitUrl;
  String? sshUrl;
  String? cloneUrl;
  String? svnUrl;
  String? homepage;
  int? size;
  int? stargazersCount;
  int? watchersCount;
  String? language;
  bool? hasIssues;
  bool? hasProjects;
  bool? hasDownloads;
  bool? hasWiki;
  bool? hasPages;
  int? forksCount;
  String? mirrorUrl;
  bool? archived;
  bool? disabled;
  int? openIssuesCount;
  String? license;
  bool? allowForking;
  bool? isTemplate;
  List<String>? topics;
  String? visibility;
  int? forks;
  int? openIssues;
  int? watchers;
  String? defaultBranch;
  Permission? permissions;

  RepoController.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nodeId = json['node_id'];
    name = json['name'];
    fullName = json['full_name'];
    private = json['private'];
    owner = json['owner'] != null ? new Assignee.fromJson(json['owner']) : null;
    htmlUrl = json['html_url'];
    description = json['description'];
    fork = json['fork'];
    url = json['url'];
    forksUrl = json['forks_url'];
    keysUrl = json['keys_url'];
    collaboratorsUrl = json['collaborators_url'];
    teamsUrl = json['teams_url'];
    hooksUrl = json['hooks_url'];
    issueEventsUrl = json['issue_events_url'];
    eventsUrl = json['events_url'];
    assigneesUrl = json['assignees_url'];
    branchesUrl = json['branches_url'];
    tagsUrl = json['tags_url'];
    blobsUrl = json['blobs_url'];
    gitTagsUrl = json['git_tags_url'];
    gitRefsUrl = json['git_refs_url'];
    treesUrl = json['trees_url'];
    statusesUrl = json['statuses_url'];
    languagesUrl = json['languages_url'];
    stargazersUrl = json['stargazers_url'];
    contributorsUrl = json['contributors_url'];
    subscribersUrl = json['subscribers_url'];
    subscriptionUrl = json['subscription_url'];
    commitsUrl = json['commits_url'];
    gitCommitsUrl = json['git_commits_url'];
    commentsUrl = json['comments_url'];
    issueCommentUrl = json['issue_comment_url'];
    contentsUrl = json['contents_url'];
    compareUrl = json['compare_url'];
    mergesUrl = json['merges_url'];
    archiveUrl = json['archive_url'];
    downloadsUrl = json['downloads_url'];
    issuesUrl = json['issues_url'];
    pullsUrl = json['pulls_url'];
    milestonesUrl = json['milestones_url'];
    notificationsUrl = json['notifications_url'];
    labelsUrl = json['labels_url'];
    releasesUrl = json['releases_url'];
    deploymentsUrl = json['deployments_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pushedAt = json['pushed_at'];
    gitUrl = json['git_url'];
    sshUrl = json['ssh_url'];
    cloneUrl = json['clone_url'];
    svnUrl = json['svn_url'];
    homepage = json['homepage'];
    size = json['size'];
    stargazersCount = json['stargazers_count'];
    watchersCount = json['watchers_count'];
    language = json['language'];
    hasIssues = json['has_issues'];
    hasProjects = json['has_projects'];
    hasDownloads = json['has_downloads'];
    hasWiki = json['has_wiki'];
    hasPages = json['has_pages'];
    forksCount = json['forks_count'];
    mirrorUrl = json['mirror_url'];
    archived = json['archived'];
    disabled = json['disabled'];
    openIssuesCount = json['open_issues_count'];
    license = json['license'];
    allowForking = json['allow_forking'];
    isTemplate = json['is_template'];
    if (json['topics'] != null) {
      topics = <String>[];
      json['topics'].forEach((v) {
        topics!.add(v);
      });
    }
    visibility = json['visibility'];
    forks = json['forks'];
    openIssues = json['open_issues'];
    watchers = json['watchers'];
    defaultBranch = json['default_branch'];
    permissions = json['permissions'] != null
        ? new Permission.fromJson(json['permissions'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['node_id'] = this.nodeId;
    data['name'] = this.name;
    data['full_name'] = this.fullName;
    data['private'] = this.private;
    if (this.owner != null) {
      data['owner'] = this.owner!.toJson();
    }
    data['html_url'] = this.htmlUrl;
    data['description'] = this.description;
    data['fork'] = this.fork;
    data['url'] = this.url;
    data['forks_url'] = this.forksUrl;
    data['keys_url'] = this.keysUrl;
    data['collaborators_url'] = this.collaboratorsUrl;
    data['teams_url'] = this.teamsUrl;
    data['hooks_url'] = this.hooksUrl;
    data['issue_events_url'] = this.issueEventsUrl;
    data['events_url'] = this.eventsUrl;
    data['assignees_url'] = this.assigneesUrl;
    data['branches_url'] = this.branchesUrl;
    data['tags_url'] = this.tagsUrl;
    data['blobs_url'] = this.blobsUrl;
    data['git_tags_url'] = this.gitTagsUrl;
    data['git_refs_url'] = this.gitRefsUrl;
    data['trees_url'] = this.treesUrl;
    data['statuses_url'] = this.statusesUrl;
    data['languages_url'] = this.languagesUrl;
    data['stargazers_url'] = this.stargazersUrl;
    data['contributors_url'] = this.contributorsUrl;
    data['subscribers_url'] = this.subscribersUrl;
    data['subscription_url'] = this.subscriptionUrl;
    data['commits_url'] = this.commitsUrl;
    data['git_commits_url'] = this.gitCommitsUrl;
    data['comments_url'] = this.commentsUrl;
    data['issue_comment_url'] = this.issueCommentUrl;
    data['contents_url'] = this.contentsUrl;
    data['compare_url'] = this.compareUrl;
    data['merges_url'] = this.mergesUrl;
    data['archive_url'] = this.archiveUrl;
    data['downloads_url'] = this.downloadsUrl;
    data['issues_url'] = this.issuesUrl;
    data['pulls_url'] = this.pullsUrl;
    data['milestones_url'] = this.milestonesUrl;
    data['notifications_url'] = this.notificationsUrl;
    data['labels_url'] = this.labelsUrl;
    data['releases_url'] = this.releasesUrl;
    data['deployments_url'] = this.deploymentsUrl;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['pushed_at'] = this.pushedAt;
    data['git_url'] = this.gitUrl;
    data['ssh_url'] = this.sshUrl;
    data['clone_url'] = this.cloneUrl;
    data['svn_url'] = this.svnUrl;
    data['homepage'] = this.homepage;
    data['size'] = this.size;
    data['stargazers_count'] = this.stargazersCount;
    data['watchers_count'] = this.watchersCount;
    data['language'] = this.language;
    data['has_issues'] = this.hasIssues;
    data['has_projects'] = this.hasProjects;
    data['has_downloads'] = this.hasDownloads;
    data['has_wiki'] = this.hasWiki;
    data['has_pages'] = this.hasPages;
    data['forks_count'] = this.forksCount;
    data['mirror_url'] = this.mirrorUrl;
    data['archived'] = this.archived;
    data['disabled'] = this.disabled;
    data['open_issues_count'] = this.openIssuesCount;
    data['license'] = this.license;
    data['allow_forking'] = this.allowForking;
    data['is_template'] = this.isTemplate;
    if (this.topics != null) {
      data['topics'] = this.topics!.map<String>((v) => v).toList();
    }
    data['visibility'] = this.visibility;
    data['forks'] = this.forks;
    data['open_issues'] = this.openIssues;
    data['watchers'] = this.watchers;
    data['default_branch'] = this.defaultBranch;
    if (this.permissions != null) {
      data['permissions'] = this.permissions!.toJson();
    }
    return data;
  }

  static RepoController fromJSONStr(String value) {
    Map<String, dynamic> mapedRepo = json.decode(value);
    return RepoController.fromJson(mapedRepo);
  }

  String toJSONStr() {
    return json.encode(toJson());
  }

  void update() {
    notifyListeners();
  }
}