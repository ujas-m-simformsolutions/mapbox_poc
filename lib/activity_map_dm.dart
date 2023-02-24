class ActivityMapDm {
  ActivityMapDm({
    required this.pois,
    required this.denseActivities,
  });

  List<List<double>> pois;
  DenseActivities denseActivities;

  factory ActivityMapDm.fromJson(Map<String, dynamic> json) => ActivityMapDm(
        pois: List<List<double>>.from(json["pois"]
            .map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
        denseActivities: DenseActivities.fromJson(json["denseActivities"]),
      );

  Map<String, dynamic> toJson() => {
        "pois": List<dynamic>.from(
            pois.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "denseActivities": denseActivities.toJson(),
      };
}

class DenseActivities {
  DenseActivities({
    required this.denseActivity,
  });

  List<DenseActivity> denseActivity;

  factory DenseActivities.fromJson(Map<String, dynamic> json) =>
      DenseActivities(
        denseActivity: List<DenseActivity>.from(
            json["denseActivity"].map((x) => DenseActivity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "denseActivity":
            List<dynamic>.from(denseActivity.map((x) => x.toJson())),
      };
}

class DenseActivity {
  DenseActivity({
    required this.latLng,
    required this.density,
  });

  List<double> latLng;
  int density;

  factory DenseActivity.fromJson(Map<String, dynamic> json) => DenseActivity(
        latLng: List<double>.from(json["latLng"].map((x) => x?.toDouble())),
        density: json["density"],
      );

  Map<String, dynamic> toJson() => {
        "latLng": List<dynamic>.from(latLng.map((x) => x)),
        "density": density,
      };
}
