class Label {
  int? id;
	String? nodeId;
	String? url;
	String? name;
	String? color;
	bool? isDefault;
	String? description;

	Label ({
    this.id,
    this.nodeId,
    this.url,
    this.name,
    this.color,
    this.isDefault,
    this.description
  });

  Label.fromJson(Map<String, dynamic> json) {
		id = json['id'];
		nodeId = json['node_id'];
		url = json['url'];
		name = json['name'];
		color = json['color'];
		isDefault = json['default'];
		description = json['description'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['id'] = this.id;
		data['node_id'] = this.nodeId;
		data['url'] = this.url;
		data['name'] = this.name;
		data['color'] = this.color;
		data['default'] = this.isDefault;
		data['description'] = this.description;
		return data;
	}
}