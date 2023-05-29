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
		final Map<String, dynamic> data = <String, dynamic>{};
		data['url'] = url;
		data['total_count'] = totalCount;
		data['+1'] = plusOne;
		data['-1'] = minusOne;
		data['laugh'] = laugh;
		data['hooray'] = hooray;
		data['confused'] = confused;
		data['heart'] = heart;
		data['rocket'] = rocket;
		data['eyes'] = eyes;
		return data;
	}
}