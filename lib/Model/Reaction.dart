class Reaction {
	String? url;
	int? totalCount;
	int? plusOne;
	int? minusOne;
	int? laugh;
	int? hooray;
	int? confused;
	int? heart;
	int? rocket;
	int? eyes;

	Reaction({
    this.url,
    this.totalCount,
    this.plusOne,
    this.minusOne,
    this.laugh,
    this.hooray,
    this.confused,
    this.heart,
    this.rocket,
    this.eyes
  });

	Reaction.fromJson(Map<String, dynamic> json) {
		url = json['url'];
		totalCount = json['total_count'];
		plusOne = json['+1'];
		minusOne = json['-1'];
		laugh = json['laugh'];
		hooray = json['hooray'];
		confused = json['confused'];
		heart = json['heart'];
		rocket = json['rocket'];
		eyes = json['eyes'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['url'] = this.url;
		data['total_count'] = this.totalCount;
		data['+1'] = this.plusOne;
		data['-1'] = this.minusOne;
		data['laugh'] = this.laugh;
		data['hooray'] = this.hooray;
		data['confused'] = this.confused;
		data['heart'] = this.heart;
		data['rocket'] = this.rocket;
		data['eyes'] = this.eyes;
		return data;
	}
}