class Permission {
  bool? admin;
  bool? maintain;
  bool? push;
  bool? triage;
  bool? pull;

  Permission({
    this.admin,
    this.maintain,
    this.push,
    this.triage,
    this.pull
  });

  Permission.fromJson(Map<String, dynamic> json) {
    admin = json['admin'];
    maintain = json['maintain'];
    push = json['push'];
    triage = json['triage'];
    pull = json['pull'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['admin'] = admin;
    data['maintain'] = maintain;
    data['push'] = push;
    data['triage'] = triage;
    data['pull'] = pull;
    return data;
  }
}