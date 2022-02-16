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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['admin'] = this.admin;
    data['maintain'] = this.maintain;
    data['push'] = this.push;
    data['triage'] = this.triage;
    data['pull'] = this.pull;
    return data;
  }
}