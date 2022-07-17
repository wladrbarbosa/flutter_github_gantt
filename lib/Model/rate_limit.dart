class RateLimit {
  Resources? resources;
  Core? rate;

  RateLimit({this.resources, this.rate});

  RateLimit.fromJson(Map<String, dynamic> json) {
    resources = json['resources'] != null
        ? Resources.fromJson(json['resources'])
        : null;
    rate = json['rate'] != null ? Core.fromJson(json['rate']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (resources != null) {
      data['resources'] = resources!.toJson();
    }
    if (rate != null) {
      data['rate'] = rate!.toJson();
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
    core = json['core'] != null ? Core.fromJson(json['core']) : null;
    search = json['search'] != null ? Core.fromJson(json['search']) : null;
    graphql =
        json['graphql'] != null ? Core.fromJson(json['graphql']) : null;
    integrationManifest = json['integration_manifest'] != null
        ? Core.fromJson(json['integration_manifest'])
        : null;
    sourceImport = json['source_import'] != null
        ? Core.fromJson(json['source_import'])
        : null;
    codeScanningUpload = json['code_scanning_upload'] != null
        ? Core.fromJson(json['code_scanning_upload'])
        : null;
    actionsRunnerRegistration = json['actions_runner_registration'] != null
        ? Core.fromJson(json['actions_runner_registration'])
        : null;
    scim = json['scim'] != null ? Core.fromJson(json['scim']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (core != null) {
      data['core'] = core!.toJson();
    }
    if (search != null) {
      data['search'] = search!.toJson();
    }
    if (graphql != null) {
      data['graphql'] = graphql!.toJson();
    }
    if (integrationManifest != null) {
      data['integration_manifest'] = integrationManifest!.toJson();
    }
    if (sourceImport != null) {
      data['source_import'] = sourceImport!.toJson();
    }
    if (codeScanningUpload != null) {
      data['code_scanning_upload'] = codeScanningUpload!.toJson();
    }
    if (actionsRunnerRegistration != null) {
      data['actions_runner_registration'] =
          actionsRunnerRegistration!.toJson();
    }
    if (scim != null) {
      data['scim'] = scim!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['limit'] = limit;
    data['used'] = used;
    data['remaining'] = remaining;
    data['reset'] = reset;
    return data;
  }
}