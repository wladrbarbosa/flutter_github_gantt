class RateLimit {
  Resources? resources;
  Core? rate;

  RateLimit({this.resources, this.rate});

  RateLimit.fromJson(Map<String, dynamic> json) {
    resources = json['resources'] != null
        ? new Resources.fromJson(json['resources'])
        : null;
    rate = json['rate'] != null ? new Core.fromJson(json['rate']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.resources != null) {
      data['resources'] = this.resources!.toJson();
    }
    if (this.rate != null) {
      data['rate'] = this.rate!.toJson();
    }
    return data;
  }
}

class Resources {
  Core? core;
  Core? search;
  Core? graphql;
  Core? integrationManifest;
  Core? sourceImport;
  Core? codeScanningUpload;
  Core? actionsRunnerRegistration;
  Core? scim;

  Resources(
      {this.core,
      this.search,
      this.graphql,
      this.integrationManifest,
      this.sourceImport,
      this.codeScanningUpload,
      this.actionsRunnerRegistration,
      this.scim});

  Resources.fromJson(Map<String, dynamic> json) {
    core = json['core'] != null ? new Core.fromJson(json['core']) : null;
    search = json['search'] != null ? new Core.fromJson(json['search']) : null;
    graphql =
        json['graphql'] != null ? new Core.fromJson(json['graphql']) : null;
    integrationManifest = json['integration_manifest'] != null
        ? new Core.fromJson(json['integration_manifest'])
        : null;
    sourceImport = json['source_import'] != null
        ? new Core.fromJson(json['source_import'])
        : null;
    codeScanningUpload = json['code_scanning_upload'] != null
        ? new Core.fromJson(json['code_scanning_upload'])
        : null;
    actionsRunnerRegistration = json['actions_runner_registration'] != null
        ? new Core.fromJson(json['actions_runner_registration'])
        : null;
    scim = json['scim'] != null ? new Core.fromJson(json['scim']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.core != null) {
      data['core'] = this.core!.toJson();
    }
    if (this.search != null) {
      data['search'] = this.search!.toJson();
    }
    if (this.graphql != null) {
      data['graphql'] = this.graphql!.toJson();
    }
    if (this.integrationManifest != null) {
      data['integration_manifest'] = this.integrationManifest!.toJson();
    }
    if (this.sourceImport != null) {
      data['source_import'] = this.sourceImport!.toJson();
    }
    if (this.codeScanningUpload != null) {
      data['code_scanning_upload'] = this.codeScanningUpload!.toJson();
    }
    if (this.actionsRunnerRegistration != null) {
      data['actions_runner_registration'] =
          this.actionsRunnerRegistration!.toJson();
    }
    if (this.scim != null) {
      data['scim'] = this.scim!.toJson();
    }
    return data;
  }
}

class Core {
  int? limit;
  int? used;
  int? remaining;
  int? reset;

  Core({this.limit, this.used, this.remaining, this.reset});

  Core.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    used = json['used'];
    remaining = json['remaining'];
    reset = json['reset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['limit'] = this.limit;
    data['used'] = this.used;
    data['remaining'] = this.remaining;
    data['reset'] = this.reset;
    return data;
  }
}